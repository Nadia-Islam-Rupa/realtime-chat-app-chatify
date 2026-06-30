/// Named route constants used throughout the app.
/// Always reference these instead of raw strings to avoid typos.
abstract final class RouteNames {
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String createProfile = '/create-profile';
  static const String home = '/home';
  static const String chat = '/chat';
  // userId is passed as a path parameter: /profile/:userId
  static const String profileView = '/profile/:userId';
  static const String editProfile = '/edit-profile';
  static const String friendsList = '/friends-list';
}
