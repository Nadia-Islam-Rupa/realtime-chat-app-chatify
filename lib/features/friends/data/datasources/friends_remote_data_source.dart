import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_request.dart';
import '../models/friend_request_model.dart';

part 'friends_remote_data_source.g.dart';

// ---------------------------------------------------------------------------
// Contract
// ---------------------------------------------------------------------------

abstract class FriendsRemoteDataSource {
  Stream<List<Friend>> getFriendsList(String userId);
  Stream<List<FriendRequest>> getPendingReceivedRequests(String userId);
  Stream<List<FriendRequest>> getSentRequests(String userId);
  Future<FriendRequest> sendFriendRequest(
      String senderId, String receiverId);
  Future<void> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
  Future<void> cancelFriendRequest(String requestId);
  Future<void> removeFriend(String userId, String friendId);
  Future<List<Profile>> searchUsersByName(
      String query, String currentUserId);
  /// Returns every profile except [currentUserId], ordered by name.
  Future<List<Profile>> getAllUsers(String currentUserId);
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  final SupabaseClient _client;
  FriendsRemoteDataSourceImpl(this._client);

  // ── Friends list ──────────────────────────────────────────────────────────

  @override
  Stream<List<Friend>> getFriendsList(String userId) {
    return _client
        .from(AppConstants.friendsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows
            .map((r) => Friend(
                  id: r['id'] as String,
                  userId: r['user_id'] as String,
                  friendId: r['friend_id'] as String,
                  createdAt: DateTime.parse(r['created_at'] as String),
                ))
            .toList());
  }

  // ── Pending received requests ──────────────────────────────────────────────

  @override
  Stream<List<FriendRequest>> getPendingReceivedRequests(String userId) {
    return _client
        .from(AppConstants.friendRequestsTable)
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .map((rows) => rows
            .where((r) => r['status'] == 'pending')
            .map((r) => FriendRequestModel.fromMap(r))
            .toList());
  }

  // ── Sent requests ─────────────────────────────────────────────────────────

  @override
  Stream<List<FriendRequest>> getSentRequests(String userId) {
    return _client
        .from(AppConstants.friendRequestsTable)
        .stream(primaryKey: ['id'])
        .eq('sender_id', userId)
        .map((rows) => rows
            .where((r) => r['status'] == 'pending')
            .map((r) => FriendRequestModel.fromMap(r))
            .toList());
  }

  // ── Send friend request ───────────────────────────────────────────────────

  @override
  Future<FriendRequest> sendFriendRequest(
      String senderId, String receiverId) async {
    try {
      final data = await _client
          .from(AppConstants.friendRequestsTable)
          .insert({
            'sender_id': senderId,
            'receiver_id': receiverId,
            'status': 'pending',
          })
          .select()
          .single();
      return FriendRequestModel.fromMap(data);
    } on PostgrestException catch (e) {
      log('[FriendsDS] sendFriendRequest error: ${e.message}');
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ── Accept ────────────────────────────────────────────────────────────────

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      // 1. Fetch the request to know both sides
      final req = await _client
          .from(AppConstants.friendRequestsTable)
          .select()
          .eq('id', requestId)
          .single();

      final senderId = req['sender_id'] as String;
      final receiverId = req['receiver_id'] as String;

      // 2. Mark request accepted
      await _client
          .from(AppConstants.friendRequestsTable)
          .update({'status': 'accepted'})
          .eq('id', requestId);

      // 3. Insert both-direction rows in the friends table
      await _client.from(AppConstants.friendsTable).upsert([
        {'user_id': receiverId, 'friend_id': senderId},
        {'user_id': senderId, 'friend_id': receiverId},
      ]);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ── Reject ────────────────────────────────────────────────────────────────

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _client
          .from(AppConstants.friendRequestsTable)
          .update({'status': 'rejected'})
          .eq('id', requestId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ── Cancel sent request ───────────────────────────────────────────────────

  @override
  Future<void> cancelFriendRequest(String requestId) async {
    try {
      await _client
          .from(AppConstants.friendRequestsTable)
          .delete()
          .eq('id', requestId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ── Remove friend ─────────────────────────────────────────────────────────

  @override
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      // Delete both directions
      await _client
          .from(AppConstants.friendsTable)
          .delete()
          .eq('user_id', userId)
          .eq('friend_id', friendId);
      await _client
          .from(AppConstants.friendsTable)
          .delete()
          .eq('user_id', friendId)
          .eq('friend_id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ── Search users ──────────────────────────────────────────────────────────

  @override
  Future<List<Profile>> searchUsersByName(
      String query, String currentUserId) async {
    try {
      final rows = await _client
          .from(AppConstants.profilesTable)
          .select()
          .ilike('name', '%$query%')
          .neq('id', currentUserId)
          .limit(30);
      return (rows as List)
          .map((r) => ProfileModel.fromMap(r as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ── Get all users ─────────────────────────────────────────────────────────

  @override
  Future<List<Profile>> getAllUsers(String currentUserId) async {
    try {
      final rows = await _client
          .from(AppConstants.profilesTable)
          .select()
          .neq('id', currentUserId)
          .order('name', ascending: true)
          .limit(200);
      return (rows as List)
          .map((r) => ProfileModel.fromMap(r as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@riverpod
FriendsRemoteDataSource friendsRemoteDataSource(
    FriendsRemoteDataSourceRef ref) {
  return FriendsRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}
