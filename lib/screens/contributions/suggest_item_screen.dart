import 'package:flutter/material.dart';

import '../../config/user_session.dart';
import '../../services/contribution_service.dart';
import '../../theme/app_theme.dart';
import '../../services/location_service.dart';
import '../../config/feature_flags.dart';

class SuggestItemScreen extends StatefulWidget {
  final bool isEditMode;
  final String? targetItemId;

  final String initialItemName;
  final String initialRestaurantName;
  final String initialCity;
  final String initialAreaName;
  final String initialCategory;
  final String initialSubCategory;
  final double? initialPrice;
  final String initialCurrency;
  final bool? initialIsVeg;
  final String initialNote;
  final double? initialLatitude;
  final double? initialLongitude;

  const SuggestItemScreen({
    super.key,
    this.isEditMode = false,
    this.targetItemId,
    this.initialItemName = '',
    this.initialRestaurantName = '',
    this.initialCity = '',
    this.initialAreaName = '',
    this.initialCategory = '',
    this.initialSubCategory = '',
    this.initialPrice,
    this.initialCurrency = 'INR',
    this.initialIsVeg,
    this.initialNote = '',
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<SuggestItemScreen> createState() => _SuggestItemScreenState();
}

class _SuggestItemScreenState extends State<SuggestItemScreen> {
  final ContributionService _contributionService = ContributionService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _itemController;
  late final TextEditingController _restaurantController;
  late final TextEditingController _cityController;
  late final TextEditingController _areaController;
  late final TextEditingController _categoryController;
  late final TextEditingController _subCategoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _noteController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  bool? _isVeg;
  bool _isSubmitting = false;

  /// Controls whether optional fields are expanded or collapsed.
  ///
  /// Launch UX decision:
  /// - keep the form short by default
  /// - allow power users to add more detail only if they want
  bool _showOptionalDetails = false;

  /// Controls whether the optional location section is expanded.
  bool _showLocationSection = false;

  bool get _isAdmin => (UserSession.role ?? '').toUpperCase() == 'ADMIN';

  @override
  void initState() {
    super.initState();
    _itemController = TextEditingController(text: widget.initialItemName);
    _restaurantController =
        TextEditingController(text: widget.initialRestaurantName);
    _cityController = TextEditingController(text: widget.initialCity);
    _areaController = TextEditingController(text: widget.initialAreaName);
    _categoryController =
        TextEditingController(text: widget.initialCategory);
    _subCategoryController =
        TextEditingController(text: widget.initialSubCategory);
    _priceController = TextEditingController(
      text: widget.initialPrice?.toString() ?? '',
    );
    _currencyController =
        TextEditingController(text: widget.initialCurrency);
    _noteController = TextEditingController(text: widget.initialNote);
    _latitudeController = TextEditingController(
      text: widget.initialLatitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.initialLongitude?.toString() ?? '',
    );

    _isVeg = widget.initialIsVeg;

    if (widget.isEditMode &&
        (widget.targetItemId == null || widget.targetItemId!.trim().isEmpty)) {
      throw ArgumentError(
        'targetItemId is required when SuggestItemScreen is used in edit mode.',
      );
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    _restaurantController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _categoryController.dispose();
    _subCategoryController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _noteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _isSubmitting) return;

    /// Guest users can open the form and explore it,
    /// but they must log in before final submission.
    if (!UserSession.isLoggedIn) {
      _showSnack('Please login to submit items.');
      return;
    }

    final lat = _tryParseDouble(_latitudeController.text);
    final lng = _tryParseDouble(_longitudeController.text);

    if ((lat == null) != (lng == null)) {
      _showSnack('Please provide both latitude and longitude together.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.isEditMode) {
        await _contributionService.submitItemEditSuggestion(
          targetItemId: widget.targetItemId!,
          itemName: _itemController.text,
          restaurantName: _restaurantController.text,
          city: _cityController.text,
          areaName: _areaController.text,
          category: _categoryController.text,
          subCategory: _subCategoryController.text,
          price: _tryParseDouble(_priceController.text),
          isVeg: _isVeg,
          note: _noteController.text,
          latitude: lat,
          longitude: lng,
        );
      } else {
        await _contributionService.submitSuggestion(
          itemName: _itemController.text,
          restaurantName: _restaurantController.text,
          city: _cityController.text,
          areaName: _areaController.text,
          category: _categoryController.text,
          subCategory: _subCategoryController.text,
          price: _tryParseDouble(_priceController.text),
          currency: _currencyController.text,
          isVeg: _isVeg,
          note: _noteController.text,
          latitude: lat,
          longitude: lng,
        );
      }

      if (!mounted) return;
      _showSnack(
        widget.isEditMode
            ? 'Edit suggestion submitted for review.'
            : 'Suggestion submitted successfully.',
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not submit suggestion. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  double? _tryParseDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Uses device current location to auto-fill:
  /// - latitude
  /// - longitude
  /// - city
  /// - area
  ///
  /// UX decision:
  /// - coordinates should always refresh from current location
  /// - manually entered city/area should not be overwritten silently
  /// - city/area are auto-filled only if currently empty
  /// - reverse geocoding failure should not block coordinate fill
  Future<void> _useCurrentLocation() async {
    if (_isSubmitting) return;

    try {
      final AppLocationResult? location =
      await LocationService.getCurrentLocationWithAddress();

      if (location == null) {
        _showSnack(
          'Current location is unavailable. You can still enter city and area manually.',
        );
        return;
      }

      setState(() {
        _latitudeController.text = location.latitude.toStringAsFixed(6);
        _longitudeController.text = location.longitude.toStringAsFixed(6);

        if ((location.city ?? '').trim().isNotEmpty) {
          _cityController.text = location.city!.trim();
        }

        if ((location.areaName ?? '').trim().isNotEmpty) {
          _areaController.text = location.areaName!.trim();
        }
      });

      _showSnack('Current location added.');
    } catch (_) {
      _showSnack(
        'Could not fetch current location. Please try again or enter manually.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.fog,
        foregroundColor: AppTheme.ink,
        title: Text(
          widget.isEditMode ? 'Suggest correction' : 'Suggest an item',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: AppTheme.snow,
              disabledBackgroundColor: AppTheme.pebble,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.snow,
              ),
            )
                : Text(
              widget.isEditMode ? 'Submit correction' : 'Submit suggestion',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildHeroCard(),
              if (widget.isEditMode) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.offWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.silver),
                  ),
                  child: const Text(
                    'Suggest a correction for this item. Your changes will go live only after admin approval.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.slate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _sectionCard(
                title: 'Basic details',
                children: [
                  _textField(
                    controller: _itemController,
                    label: 'Item name',
                    hint: 'Example: Cheese Dabeli',
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter item name' : null,
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    controller: _restaurantController,
                    label: 'Restaurant name',
                    hint: 'Example: Jay Bhavani',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter restaurant name'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          controller: _cityController,
                          label: 'City',
                          hint: 'Ahmedabad',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter city'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(
                          controller: _areaController,
                          label: 'Area',
                          hint: 'Navrangpura',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter area'
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'More details (optional)',
                subtitle: 'Add only if you want to provide extra context.',
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showOptionalDetails = !_showOptionalDetails;
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.fog,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.silver),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _showOptionalDetails
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: AppTheme.ink,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _showOptionalDetails
                                  ? 'Hide optional fields'
                                  : 'Add more details',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showOptionalDetails) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            controller: _categoryController,
                            label: 'Category',
                            hint: 'Street Food',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _textField(
                            controller: _subCategoryController,
                            label: 'Sub-category',
                            hint: 'Snacks',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _textField(
                            controller: _priceController,
                            label: 'Price',
                            hint: '80',
                            keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _textField(
                            controller: _currencyController,
                            label: 'Currency',
                            hint: 'INR',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Food type',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        _choicePill(
                          label: 'Veg',
                          selected: _isVeg == true,
                          onTap: () => setState(() => _isVeg = true),
                        ),
                        _choicePill(
                          label: 'Non-veg',
                          selected: _isVeg == false,
                          onTap: () => setState(() => _isVeg = false),
                        ),
                        _choicePill(
                          label: 'Skip',
                          selected: _isVeg == null,
                          onTap: () => setState(() => _isVeg = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _textField(
                      controller: _noteController,
                      label: 'Note',
                      hint: 'Anything helpful about this item...',
                      maxLines: 4,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Location (optional)',
                subtitle:
                'Using current location will update the city and area automatically. You can edit them again afterward if needed.',
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showLocationSection = !_showLocationSection;
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.fog,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.silver),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _showLocationSection
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: AppTheme.ink,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _showLocationSection
                                  ? 'Hide location fields'
                                  : 'Add location details',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showLocationSection) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _useCurrentLocation,
                        icon: const Icon(Icons.my_location_rounded),
                        label: const Text(
                          'Use Current Location',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accent,
                          side: const BorderSide(color: AppTheme.accent),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_isAdmin) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _textField(
                              controller: _latitudeController,
                              label: 'Latitude',
                              hint: '23.0339',
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _textField(
                              controller: _longitudeController,
                              label: 'Longitude',
                              hint: '72.5850',
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the top hero card for the Add Item screen.
  ///
  /// Messaging rule:
  /// - if rewards are enabled, mention approval/rewards
  /// - if rewards are disabled, keep only contribution motivation
  Widget _buildHeroCard() {
    final String subtitle = FeatureFlags.isRewardsEnabled
        ? 'Help others discover standout dishes and earn points once approved.'
        : 'Help others invest in great taste by sharing dishes truly worth trying.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.accentDim,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Help improve Spotzy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.stone,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.stone,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _choicePill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.ink : AppTheme.fog,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppTheme.ink : AppTheme.silver,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.snow : AppTheme.ink,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String hint = '',
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textInputAction:
          maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.fog,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines == 1 ? 14 : 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppTheme.accent,
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppTheme.error,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppTheme.error,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}