import 'dart:async';
import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/typing_status.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/typing_status_model.dart';

part 'chat_remote_data_source.g.dart';

// ---------------------------------------------------------------------------
// Contract
// ---------------------------------------------------------------------------

abstract class ChatRemoteDataSource {
  Future<Conversation> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
  );

  Stream<List<Conversation>> getConversationsList(String userId);

  Stream<List<Message>> getMessages(String conversationId);

  Future<Message> sendMessage(
    String conversationId,
    String senderId,
    String content, {
    String? mediaUrl,
    String? mediaType,
  });

  Future<void> markMessagesAsRead(String conversationId, String userId);

  Future<void> setTypingStatus(
    String conversationId,
    String userId, {
    required bool isTyping,
  });

  Stream<List<TypingStatus>> getTypingStatus(String conversationId);
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient _client;

  ChatRemoteDataSourceImpl(this._client);

  // ── getOrCreateConversation ───────────────────────────────────────────────

  @override
  Future<Conversation> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      final existing = await _client
          .from(AppConstants.conversationsTable)
          .select()
          .or(
            'and(participant_one.eq.$currentUserId,participant_two.eq.$otherUserId),'
            'and(participant_one.eq.$otherUserId,participant_two.eq.$currentUserId)',
          )
          .maybeSingle();

      if (existing != null) {
        return ConversationModel.fromMap(existing as Map<String, dynamic>);
      }

      final created = await _client
          .from(AppConstants.conversationsTable)
          .insert({
            'participant_one': currentUserId,
            'participant_two': otherUserId,
          })
          .select()
          .single();
      return ConversationModel.fromMap(created as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      log('[ChatDS] getOrCreateConversation: ${e.message}');
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ── getConversationsList — Realtime ───────────────────────────────────────
  //
  // KEY FIX: Use a plain (single-subscriber) StreamController, NOT broadcast.
  // Riverpod's StreamProvider keeps a single listener alive; broadcast would
  // miss the initial fetch event emitted before Riverpod subscribes.

  @override
  Stream<List<Conversation>> getConversationsList(String userId) {
    // ignore: close_sinks  — closed in onCancel below
    final controller = StreamController<List<Conversation>>();
    RealtimeChannel? channel;

    Future<void> fetchAndEmit() async {
      if (controller.isClosed) return;
      try {
        final rows = await _client
            .from(AppConstants.conversationsTable)
            .select()
            .or('participant_one.eq.$userId,participant_two.eq.$userId')
            .order('last_message_at', ascending: false, nullsFirst: false);

        final conversations = await _enrichConversations(
          (rows as List).cast<Map<String, dynamic>>(),
          userId,
        );

        if (!controller.isClosed) controller.add(conversations);
      } on PostgrestException catch (e) {
        if (!controller.isClosed) {
          controller.addError(ServerException(e.message));
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(UnknownException(e.toString()));
        }
      }
    }

    controller.onListen = () {
      // Fire initial fetch
      fetchAndEmit();

      // Subscribe to Realtime changes and re-fetch on any change
      channel = _client
          .channel('conversations_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: AppConstants.conversationsTable,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'participant_one',
              value: userId,
            ),
            callback: (_) => fetchAndEmit(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: AppConstants.conversationsTable,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'participant_two',
              value: userId,
            ),
            callback: (_) => fetchAndEmit(),
          )
          .subscribe();
    };

    controller.onCancel = () {
      channel?.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }

  Future<List<Conversation>> _enrichConversations(
    List<Map<String, dynamic>> rows,
    String userId,
  ) async {
    if (rows.isEmpty) return [];

    final otherIds = rows
        .map((r) {
          final p1 = r['participant_one'] as String;
          return p1 == userId ? r['participant_two'] as String : p1;
        })
        .toSet()
        .toList();

    final profileRows = await _client
        .from(AppConstants.profilesTable)
        .select()
        .inFilter('id', otherIds);

    final profileMap = <String, Profile>{
      for (final p in (profileRows as List).cast<Map<String, dynamic>>())
        p['id'] as String: ProfileModel.fromMap(p),
    };

    final convIds = rows.map((r) => r['id'] as String).toList();
    List<Map<String, dynamic>> unreadRows = [];
    if (convIds.isNotEmpty) {
      unreadRows = ((await _client
                  .from(AppConstants.messagesTable)
                  .select('conversation_id')
                  .inFilter('conversation_id', convIds)
                  .eq('is_read', false)
                  .neq('sender_id', userId)) as List)
          .cast<Map<String, dynamic>>();
    }

    final unreadCountMap = <String, int>{};
    for (final row in unreadRows) {
      final cid = row['conversation_id'] as String;
      unreadCountMap[cid] = (unreadCountMap[cid] ?? 0) + 1;
    }

    return rows.map((r) {
      final p1 = r['participant_one'] as String;
      final otherId = p1 == userId ? r['participant_two'] as String : p1;
      return ConversationModel.fromMap(
        r,
        otherParticipant: profileMap[otherId],
        unreadCount: unreadCountMap[r['id'] as String] ?? 0,
      );
    }).toList();
  }

  // ── getMessages — Realtime ────────────────────────────────────────────────

  @override
  Stream<List<Message>> getMessages(String conversationId) {
    // ignore: close_sinks
    final controller = StreamController<List<Message>>();
    RealtimeChannel? channel;

    Future<void> fetchAndEmit() async {
      if (controller.isClosed) return;
      try {
        final rows = await _client
            .from(AppConstants.messagesTable)
            .select()
            .eq('conversation_id', conversationId)
            .order('created_at', ascending: true);

        final messages = (rows as List)
            .cast<Map<String, dynamic>>()
            .map(MessageModel.fromMap)
            .toList();

        if (!controller.isClosed) controller.add(messages);
      } on PostgrestException catch (e) {
        if (!controller.isClosed) {
          controller.addError(ServerException(e.message));
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(UnknownException(e.toString()));
        }
      }
    }

    controller.onListen = () {
      fetchAndEmit();

      channel = _client
          .channel('messages_$conversationId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: AppConstants.messagesTable,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'conversation_id',
              value: conversationId,
            ),
            callback: (_) => fetchAndEmit(),
          )
          .subscribe();
    };

    controller.onCancel = () {
      channel?.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }

  // ── sendMessage ───────────────────────────────────────────────────────────

  @override
  Future<Message> sendMessage(
    String conversationId,
    String senderId,
    String content, {
    String? mediaUrl,
    String? mediaType,
  }) async {
    try {
      final msgRow = await _client
          .from(AppConstants.messagesTable)
          .insert({
            'conversation_id': conversationId,
            'sender_id': senderId,
            'content': content.isEmpty ? null : content,
            'media_url': mediaUrl,
            'media_type': mediaType,
            'is_read': false,
          })
          .select()
          .single();

      final message = MessageModel.fromMap(msgRow as Map<String, dynamic>);

      await _client.from(AppConstants.conversationsTable).update({
        'last_message':
            (mediaUrl != null && content.isEmpty) ? '📷 Photo' : content,
        'last_message_at': message.createdAt.toIso8601String(),
        'last_message_by': senderId,
      }).eq('id', conversationId);

      return message;
    } on PostgrestException catch (e) {
      log('[ChatDS] sendMessage: ${e.message}');
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ── markMessagesAsRead ────────────────────────────────────────────────────

  @override
  Future<void> markMessagesAsRead(
      String conversationId, String userId) async {
    try {
      await _client
          .from(AppConstants.messagesTable)
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ── setTypingStatus ───────────────────────────────────────────────────────

  @override
  Future<void> setTypingStatus(
    String conversationId,
    String userId, {
    required bool isTyping,
  }) async {
    try {
      await _client.from(AppConstants.typingStatusTable).upsert(
        {
          'conversation_id': conversationId,
          'user_id': userId,
          'is_typing': isTyping,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'conversation_id,user_id',
      );
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ── getTypingStatus — Realtime ────────────────────────────────────────────

  @override
  Stream<List<TypingStatus>> getTypingStatus(String conversationId) {
    // ignore: close_sinks
    final controller = StreamController<List<TypingStatus>>();
    RealtimeChannel? channel;

    Future<void> fetchAndEmit() async {
      if (controller.isClosed) return;
      try {
        final rows = await _client
            .from(AppConstants.typingStatusTable)
            .select()
            .eq('conversation_id', conversationId);

        final statuses = (rows as List)
            .cast<Map<String, dynamic>>()
            .map(TypingStatusModel.fromMap)
            .toList();

        if (!controller.isClosed) controller.add(statuses);
      } on PostgrestException catch (e) {
        if (!controller.isClosed) {
          controller.addError(ServerException(e.message));
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(UnknownException(e.toString()));
        }
      }
    }

    controller.onListen = () {
      fetchAndEmit();

      channel = _client
          .channel('typing_$conversationId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: AppConstants.typingStatusTable,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'conversation_id',
              value: conversationId,
            ),
            callback: (_) => fetchAndEmit(),
          )
          .subscribe();
    };

    controller.onCancel = () {
      channel?.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@riverpod
ChatRemoteDataSource chatRemoteDataSource(ChatRemoteDataSourceRef ref) {
  return ChatRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}
