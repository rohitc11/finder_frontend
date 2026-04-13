import 'package:flutter/material.dart';

import '../../models/admin_suggestion_model.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

class PendingSuggestionDetailScreen extends StatefulWidget {
  final AdminSuggestionModel item;

  const PendingSuggestionDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<PendingSuggestionDetailScreen> createState() =>
      _PendingSuggestionDetailScreenState();
}

class _PendingSuggestionDetailScreenState
    extends State<PendingSuggestionDetailScreen> {
  final AdminService _adminService = AdminService();

  bool _isProcessing = false;

  Future<void> _approve() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      if (widget.item.isEditSuggestion) {
        await _adminService.approveSuggestionAsEdit(widget.item.id);
      } else {
        await _adminService.approveSuggestionAsNew(widget.item.id);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      await _showMessageDialog(
        title: 'Could not approve suggestion',
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _reject() async {
    final TextEditingController reasonController = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject suggestion'),
          content: TextField(
            controller: reasonController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Optional rejection reason',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _adminService.rejectSuggestion(
        widget.item.id,
        rejectionReason: reasonController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      await _showMessageDialog(
        title: 'Could not reject suggestion',
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _showMessageDialog({
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.fog,
            foregroundColor: AppTheme.ink,
            elevation: 0,
            title: Text(
              item.itemName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(item),
                  const SizedBox(height: 20),
                  _buildMetaChips(item),
                  const SizedBox(height: 20),
                  _buildInfoCards(item),
                  const SizedBox(height: 20),
                  _buildLocationCard(item),
                  const SizedBox(height: 20),
                  _buildNotesCard(item),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.ink,
                  side: const BorderSide(color: AppTheme.silver),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Later',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isProcessing ? null : _reject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Reject',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _approve,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.snow,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Approve',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(AdminSuggestionModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              size: 28,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.itemName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.restaurantName,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.slate,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 16,
                color: AppTheme.pebble,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  [item.areaName, item.city]
                      .where((e) => e.trim().isNotEmpty)
                      .join(', ')
                      .ifEmpty('Location not available'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.pebble,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChips(AdminSuggestionModel item) {
    final chips = <Widget>[];

    if (item.category.trim().isNotEmpty) {
      chips.add(_metaChip(item.category, AppTheme.offWhite, AppTheme.ink));
    }

    if (item.subCategory.trim().isNotEmpty) {
      chips.add(_metaChip(item.subCategory, AppTheme.offWhite, AppTheme.slate));
    }

    if (item.isVeg == true) {
      chips.add(_metaChip('Veg', const Color(0xFFE8F7ED), const Color(0xFF2E7D32)));
    } else if (item.isVeg == false) {
      chips.add(_metaChip('Non-veg', const Color(0xFFFFECEA), const Color(0xFFC62828)));
    }

    chips.add(_metaChip('Pending', const Color(0xFFFFF4E5), const Color(0xFFEF6C00)));

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: chips,
    );
  }

  Widget _buildInfoCards(AdminSuggestionModel item) {
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            title: 'Price',
            value: _buildPriceText(item),
            icon: Icons.currency_rupee_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _infoCard(
            title: 'Type',
            value: item.isVeg == true
                ? 'Vegetarian'
                : item.isVeg == false
                ? 'Non-vegetarian'
                : 'Food Item',
            icon: Icons.local_dining_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(AdminSuggestionModel item) {
    final hasReadableLocation =
        item.areaName.trim().isNotEmpty || item.city.trim().isNotEmpty;
    final hasCoordinates = item.latitude != null && item.longitude != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 12),
          if (hasReadableLocation || hasCoordinates) ...[
            Text(
              hasReadableLocation
                  ? [item.areaName, item.city]
                  .where((e) => e.trim().isNotEmpty)
                  .join(', ')
                  : 'Coordinates available',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.slate,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            if (hasCoordinates) ...[
              const SizedBox(height: 10),
              Text(
                'Lat: ${item.latitude!.toStringAsFixed(6)}  •  Lng: ${item.longitude!.toStringAsFixed(6)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.stone,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ] else ...[
            const Text(
              'No location available in this suggestion.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.stone,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard(AdminSuggestionModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin notes view',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.note.trim().isNotEmpty ? item.note : 'No note added by user.',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.slate,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.slate),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.stone,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _buildPriceText(AdminSuggestionModel item) {
    if (item.price == null) {
      return '-';
    }

    if (item.currency == 'INR') {
      return '₹${item.price!.toStringAsFixed(0)}';
    }

    return '${item.currency} ${item.price!.toStringAsFixed(0)}';
  }
}

extension _StringFallbackExtension on String {
  String ifEmpty(String fallback) {
    return trim().isEmpty ? fallback : this;
  }
}