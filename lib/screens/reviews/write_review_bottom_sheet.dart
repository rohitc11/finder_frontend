import 'package:flutter/material.dart';

import '../../config/user_session.dart';
import '../../models/user_model.dart';
import '../../services/review_service.dart';
import '../../theme/app_theme.dart';
import 'package:flutter/services.dart';

/// Bottom sheet used to create a review for an item.
///
/// UX goals:
/// - very quick review submission
/// - rating first
/// - 3/4 ready-made comment suggestions
/// - optional short manual comment
class WriteReviewBottomSheet extends StatefulWidget {
  final String itemId;
  final String itemName;
  final UserModel user;

  const WriteReviewBottomSheet({
    super.key,
    required this.itemId,
    required this.itemName,
    required this.user,
  });

  @override
  State<WriteReviewBottomSheet> createState() => _WriteReviewBottomSheetState();
}

class _WriteReviewBottomSheetState extends State<WriteReviewBottomSheet> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();

  int _selectedRating = 0;
  bool _isSubmitting = false;
  String? _selectedSuggestion;

  static const int _maxWords = 20;

  List<String> get _commentSuggestions {
    if (_selectedRating >= 5) {
      return const [
        'Must try item',
        'Excellent taste and quality',
        'Loved it, would order again',
        'Best item at this place',
      ];
    }
    if (_selectedRating == 4) {
      return const [
        'Very tasty item',
        'Good taste and value',
        'Worth trying once',
        'Nice item overall',
      ];
    }
    if (_selectedRating == 3) {
      return const [
        'Average taste',
        'Okay but can improve',
        'Decent item',
        'Good, not great',
      ];
    }
    if (_selectedRating > 0) {
      return const [
        'Did not like the taste',
        'Needs improvement',
        'Not worth the price',
        'Would not order again',
      ];
    }
    return const [
      'Must try item',
      'Very tasty item',
      'Average taste',
      'Needs improvement',
    ];
  }

  int get _wordCount {
    final text = _commentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  void _applySuggestion(String suggestion) {
    setState(() {
      _selectedSuggestion = suggestion;
      _commentController.text = suggestion;
    });
  }

  Future<void> _submit() async {
    if (_selectedRating == 0 || _isSubmitting) return;

    if (_wordCount > _maxWords) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review comment can have at most 20 words.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _reviewService.addItemReview(
        itemId: widget.itemId,
        rating: _selectedRating,
        comment: _commentController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not submit review. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rate ${widget.itemName}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quick review for launch: give rating and optionally choose a short comment.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.stone,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedRating = star;
                        _selectedSuggestion = null;
                      });
                    },
                    icon: Icon(
                      _selectedRating >= star
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFFF9F0A),
                      size: 30,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quick suggestions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commentSuggestions.map((suggestion) {
                  final selected = _selectedSuggestion == suggestion;
                  return ChoiceChip(
                    label: Text(suggestion),
                    selected: selected,
                    onSelected: (_) => _applySuggestion(suggestion),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _commentController,
                minLines: 2,
                maxLines: 3,
                inputFormatters: [
                  WordLimitTextInputFormatter(maxWords: _maxWords),
                ],
                decoration: InputDecoration(
                  labelText: 'Comment (optional)',
                  hintText: 'Keep it short and useful',
                  filled: true,
                  fillColor: AppTheme.snow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) {
                  setState(() {
                    _selectedSuggestion = null;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                '$_wordCount / $_maxWords words',
                style: TextStyle(
                  fontSize: 12,
                  color:
                  _wordCount > _maxWords ? AppTheme.error : AppTheme.stone,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.snow,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Submit Review',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Input formatter that prevents typing more than the allowed word count.
///
/// Why:
/// - review comments are intentionally short for launch
/// - prevents unnecessary long comments before submit
class WordLimitTextInputFormatter extends TextInputFormatter {
  final int maxWords;

  WordLimitTextInputFormatter({required this.maxWords});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.trim();

    if (text.isEmpty) {
      return newValue;
    }

    final words = text.split(RegExp(r'\s+'));
    if (words.length <= maxWords) {
      return newValue;
    }

    return oldValue;
  }
}