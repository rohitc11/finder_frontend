import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/search_result_model.dart';
import '../services/item_service.dart';
import '../theme/app_theme.dart';

/// Item detail screen.
///
/// Responsibility:
/// - show a rich detail view for a selected food item
/// - use search result summary immediately
/// - fetch full item details from backend for richer UI
/// - act as future home for reviews and contribution info
class ItemDetailScreen extends StatefulWidget {
  final SearchResultModel summary;

  const ItemDetailScreen({
    super.key,
    required this.summary,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  /// Service used to fetch full item details.
  final ItemService _itemService = ItemService();

  /// Full item detail loaded from backend.
  ItemModel? _item;

  /// Loading state for detail fetch.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItemDetail();
  }

  /// Loads full item detail from backend.
  Future<void> _loadItemDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final item = await _itemService.fetchItemById(widget.summary.itemId);

      if (!mounted) return;

      setState(() {
        _item = item;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _item = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;

    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.fog,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppTheme.ink),
            title: Text(
              item?.itemName ?? widget.summary.itemName,
              style: const TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildBody(context, item),
          ),
        ],
      ),
    );
  }

  /// Builds the main item detail body.
  Widget _buildBody(BuildContext context, ItemModel? item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(context, item),
          const SizedBox(height: 20),
          _buildMetaChips(item),
          const SizedBox(height: 20),
          _buildInfoCards(context, item),
          const SizedBox(height: 20),
          _buildDescriptionCard(context, item),
          if (_isLoading) ...[
            const SizedBox(height: 20),
            _buildLoadingCard(context),
          ],
          if (!_isLoading && item == null) ...[
            const SizedBox(height: 20),
            _buildErrorCard(context),
          ],
        ],
      ),
    );
  }

  /// Builds the main hero card for the item.
  Widget _buildHeroCard(BuildContext context, ItemModel? item) {
    final displayName = item?.itemName ?? widget.summary.itemName;
    final displayRestaurant = item?.restaurantName ?? widget.summary.restaurantName;
    final displayArea = item?.areaName ?? widget.summary.areaName;
    final displayCity = item?.city ?? widget.summary.city;
    final displayRating = item?.avgItemRating ?? widget.summary.avgItemRating;
    final displayRatingCount = item?.ratingCount ?? widget.summary.ratingCount;

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
            displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            displayRestaurant,
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
                Icons.star_rounded,
                color: Color(0xFFFF9F0A),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                displayRating != null ? displayRating.toStringAsFixed(1) : '-',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${displayRatingCount ?? 0})',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.stone,
                ),
              ),
              const Spacer(),
              if (widget.summary.distanceInKm != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.offWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.summary.distanceInKm!.toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slate,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
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
                  '$displayArea, $displayCity',
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

  /// Builds category/status chips.
  Widget _buildMetaChips(ItemModel? item) {
    final chips = <Widget>[];

    if (item?.category.isNotEmpty == true) {
      chips.add(_metaChip(item!.category, AppTheme.offWhite, AppTheme.ink));
    }

    if (item?.subCategory.isNotEmpty == true) {
      chips.add(_metaChip(item!.subCategory, AppTheme.offWhite, AppTheme.slate));
    }

    if (item != null && item.isVeg) {
      chips.add(_metaChip('Veg', const Color(0xFFE8F7ED), const Color(0xFF2E7D32)));
    }

    if (item != null && item.isAvailable) {
      chips.add(_metaChip('Available', const Color(0xFFEAF4FF), const Color(0xFF1565C0)));
    }

    if (item != null && item.isVerified) {
      chips.add(_metaChip('Verified', const Color(0xFFFFF4E5), const Color(0xFFEF6C00)));
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: chips,
    );
  }

  /// Builds the main info cards row.
  Widget _buildInfoCards(BuildContext context, ItemModel? item) {
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
            value: item?.isVeg == true ? 'Vegetarian' : 'Food Item',
            icon: Icons.local_dining_rounded,
          ),
        ),
      ],
    );
  }

  /// Builds one info card.
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

  /// Builds descriptive summary card.
  Widget _buildDescriptionCard(BuildContext context, ItemModel? item) {
    final parts = <String>[];

    if (item?.restaurantName.isNotEmpty == true) {
      parts.add('Served at ${item!.restaurantName}');
    }

    if (item?.category.isNotEmpty == true) {
      parts.add('Category: ${item!.category}');
    }

    if (item?.subCategory.isNotEmpty == true) {
      parts.add('Sub-category: ${item!.subCategory}');
    }

    if (item?.isAvailable == true) {
      parts.add('Currently marked as available');
    }

    final description = parts.isNotEmpty
        ? parts.join(' • ')
        : 'More item details will appear here as your backend grows.';

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
          Text(
            'About this item',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
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

  /// Builds loading card shown while full details are being fetched.
  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowXs,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading more details...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.stone,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds error card if full detail request fails.
  Widget _buildErrorCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowXs,
      ),
      child: Text(
        'Could not load full item details right now.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.error,
        ),
      ),
    );
  }

  /// Builds one small meta chip.
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

  /// Builds formatted price text.
  String _buildPriceText(ItemModel? item) {
    if (item?.price == null) {
      return '-';
    }

    if (item!.currency == 'INR') {
      return '₹${item.price!.toStringAsFixed(0)}';
    }

    return '${item.currency} ${item.price!.toStringAsFixed(0)}';
  }
}