/// Model representing one autocomplete suggestion returned by backend.
class SuggestionModel {
  final String type;
  final String displayText;
  final String? secondaryText;
  final String? canonicalValue;
  final String? area;
  final String? city;
  final int? score;

  SuggestionModel({
    required this.type,
    required this.displayText,
    required this.secondaryText,
    required this.canonicalValue,
    required this.area,
    required this.city,
    required this.score,
  });

  /// Creates model from backend JSON response.
  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      type: json['type'] ?? '',
      displayText: json['displayText'] ?? '',
      secondaryText: json['secondaryText'],
      canonicalValue: json['canonicalValue'],
      area: json['area'],
      city: json['city'],
      score: json['score'],
    );
  }
}