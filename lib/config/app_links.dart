class AppLinks {
  /// Update this once your final public web URL is ready.
  static const String publicBaseUrl = 'https://spotzy.in';

  static String itemUrl(String itemId) {
    return '$publicBaseUrl/item/$itemId';
  }
}