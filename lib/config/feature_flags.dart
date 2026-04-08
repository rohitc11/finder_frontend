/// Central place for temporary launch-stage feature toggles.
///
/// Why this file exists:
/// - lets product behavior change without touching many screens
/// - useful for launch experiments
/// - keeps contribution tracking independent from rewards
class FeatureFlags {
  /// Controls whether reward-related UI should be visible.
  ///
  /// Important:
  /// - when false, only reward UI is hidden
  /// - contribution history and counters should still remain visible
  static const bool isRewardsEnabled = false;

  /// Quick actions launch toggles.
  ///
  /// Current product decision:
  /// - Best Near Me is enabled
  /// - Top Rated and Must Try stay visible but disabled until ranking/rating
  ///   logic becomes reliable enough for launch
  static const bool isBestNearMeQuickActionEnabled = true;
  static const bool isTopRatedQuickActionEnabled = false;
  static const bool isMustTryQuickActionEnabled = false;
}