/// Holds current logged-in / active user info.
///
/// Responsibility:
/// - single source of truth for userId
/// - easy to replace later with real auth/session
class UserSession {
  /// Current active user ID.
  ///
  /// For now:
  /// - hardcoded for testing
  /// Later:
  /// - will come from login / local storage
  static const String userId = '69c9313bc495ce1fa3aeb8c5';
}