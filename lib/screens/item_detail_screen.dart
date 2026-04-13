import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../config/app_links.dart';
import '../config/user_session.dart';
import '../models/item_model.dart';
import '../models/review_model.dart';
import '../models/search_result_model.dart';
import '../models/user_model.dart';
import '../services/item_service.dart';
import '../services/review_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'reviews/write_review_bottom_sheet.dart';
import '../utils/map_utils.dart';

/// Item detail screen.
///
/// Responsibility:
/// - show a rich detail view for a selected food item
/// - use search result summary immediately
/// - fetch full item details from backend for richer UI
/// - act as home for reviews and contribution info
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
  final ItemService _itemService = ItemService();
  final ReviewService _reviewService = ReviewService();
  final UserService _userService = UserService();

  UserModel? _currentUser;
  List<ReviewModel> _reviews = [];

  bool _isReviewsLoading = true;
  bool _isLoading = true;

  ItemModel? _item;

  bool get _hasCurrentUserReviewed {
    if (_currentUser == null) return false;
    return _reviews.any((review) => review.userId == _currentUser!.id);
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadItemDetail(),
      _loadCurrentUser(),
      _loadReviews(),
    ]);
  }

  Future<void> _loadCurrentUser() async {
    if (!UserSession.isLoggedIn) {
      if (!mounted) return;
      setState(() {
        _currentUser = null;
      });
      return;
    }

    try {
      final user = await _userService.fetchCurrentUser();

      if (!mounted) return;
      setState(() {
        _currentUser = user;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentUser = null;
      });
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _reviewService.fetchReviewsByItem(widget.summary.itemId);

      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _isReviewsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reviews = [];
        _isReviewsLoading = false;
      });
    }
  }

  Future<void> _openWriteReviewSheet() async {
    if (!UserSession.isLoggedIn) {
      final bool? loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

      if (loggedIn == true) {
        await _loadCurrentUser();
      } else {
        return;
      }
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load user details for review.'),
        ),
      );
      return;
    }

    if (_hasCurrentUserReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already reviewed this item.'),
        ),
      );
      return;
    }

    final bool? created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.fog,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => WriteReviewBottomSheet(
        itemId: widget.summary.itemId,
        itemName: _item?.itemName ?? widget.summary.itemName,
        user: _currentUser!,
      ),
    );

    if (created == true) {
      await Future.wait([
        _loadItemDetail(),
        _loadReviews(),
      ]);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully.'),
        ),
      );
    }
  }

  bool _shouldShowShareRating() {
    final double? rating = _item?.avgItemRating ?? widget.summary.avgItemRating;
    final int ratingCount =
        _item?.ratingCount ?? widget.summary.ratingCount ?? 0;

    return rating != null && rating >= 4.0 && ratingCount >= 20;
  }

  String _buildShareLink() {
    final itemId = _item?.id ?? widget.summary.itemId;
    return AppLinks.itemUrl(itemId);
  }

  String _buildShareMessage() {
    final itemName = (_item?.itemName ?? widget.summary.itemName).trim();
    final restaurantName =
    (_item?.restaurantName ?? widget.summary.restaurantName).trim();
    final areaName = (_item?.areaName ?? widget.summary.areaName).trim();
    final city = (_item?.city ?? widget.summary.city).trim();
    final double? rating = _item?.avgItemRating ?? widget.summary.avgItemRating;
    final String link = _buildShareLink();

    final String locationText = [
      if (areaName.isNotEmpty) areaName,
      if (city.isNotEmpty) city,
    ].join(', ').trim();

    final String headline = locationText.isNotEmpty
        ? '🔥 Must-try dish in $locationText'
        : '🔥 Must-try dish on Spotzy';

    final StringBuffer message = StringBuffer()
      ..writeln(headline)
      ..writeln()
      ..writeln('🍽 $itemName at $restaurantName');

    if (_shouldShowShareRating() && rating != null) {
      message.writeln('⭐ Rated ${rating.toStringAsFixed(1)} on Spotzy');
    }

    message
      ..writeln()
      ..writeln('👉 Discover more iconic dishes on Spotzy')
      ..write(link);

    return message.toString();
  }

  Future<void> _shareItem() async {
    final String itemName = (_item?.itemName ?? widget.summary.itemName).trim();

    await Share.share(
      _buildShareMessage(),
      subject: '$itemName on Spotzy',
    );
  }

  Future<void> _copyShareLink() async {
    await Clipboard.setData(
      ClipboardData(text: _buildShareLink()),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item link copied'),
      ),
    );
  }

  Future<void> _openShareSheet() async {
    final itemName = (_item?.itemName ?? widget.summary.itemName).trim();
    final restaurantName =
    (_item?.restaurantName ?? widget.summary.restaurantName).trim();
    final areaName = (_item?.areaName ?? widget.summary.areaName).trim();
    final city = (_item?.city ?? widget.summary.city).trim();
    final double? rating = _item?.avgItemRating ?? widget.summary.avgItemRating;

    final String locationText = [
      if (areaName.isNotEmpty) areaName,
      if (city.isNotEmpty) city,
    ].join(', ').trim();

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.snow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.silver,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Share this find',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.fog,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        restaurantName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slate,
                        ),
                      ),
                      if (locationText.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          locationText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.stone,
                          ),
                        ),
                      ],
                      if (_shouldShowShareRating() && rating != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFFFA000),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.ink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _copyShareLink();
                        },
                        icon: const Icon(Icons.link_rounded),
                        label: const Text(
                          'Copy link',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.ink,
                          side: const BorderSide(color: AppTheme.silver),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _shareItem();
                        },
                        icon: const Icon(Icons.share_rounded),
                        label: const Text(
                          'Share now',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: AppTheme.snow,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sharing helps more people discover standout dishes on Spotzy.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.stone,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _item = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _openItemLocationInMap(ItemModel? item) async {
    final double? latitude = item?.latitude;
    final double? longitude = item?.longitude;

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available for this item.'),
        ),
      );
      return;
    }

    try {
      await MapUtils.openDirections(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open map. Please try again.'),
        ),
      );
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
            actions: [
              IconButton(
                tooltip: 'Share item',
                onPressed: _openShareSheet,
                icon: const Icon(Icons.share_rounded),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildBody(context, item),
          ),
        ],
      ),
    );
  }

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
          _buildLocationCard(context, item),
          const SizedBox(height: 20),
          _buildDescriptionCard(context, item),
          const SizedBox(height: 20),
          _buildWriteReviewCard(context),
          const SizedBox(height: 20),
          _buildReviewsSection(context),
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
                  [
                    if (displayArea.trim().isNotEmpty) displayArea,
                    if (displayCity.trim().isNotEmpty) displayCity,
                  ].join(', ').ifEmpty('Location not available'),
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

  Widget _buildLocationCard(BuildContext context, ItemModel? item) {
    final String area = (item?.areaName ?? widget.summary.areaName).trim();
    final String city = (item?.city ?? widget.summary.city).trim();
    final double? latitude = item?.latitude;
    final double? longitude = item?.longitude;

    final bool hasReadableLocation = area.isNotEmpty || city.isNotEmpty;
    final bool hasCoordinates = latitude != null && longitude != null;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (hasCoordinates)
                TextButton.icon(
                  onPressed: () => _openItemLocationInMap(item),
                  icon: const Icon(
                    Icons.directions_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Directions',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                  ),
                )
            ],
          ),
          const SizedBox(height: 12),
          if (hasReadableLocation || hasCoordinates) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppTheme.pebble,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasReadableLocation
                        ? [if (area.isNotEmpty) area, if (city.isNotEmpty) city]
                        .join(', ')
                        : 'Coordinates available',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.slate,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (hasCoordinates) ...[
              const SizedBox(height: 10),
              Text(
                'Lat: ${latitude.toStringAsFixed(6)}  •  Lng: ${longitude.toStringAsFixed(6)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.stone,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tap the map icon to open directions.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.stone,
                  height: 1.4,
                ),
              ),
            ],
          ] else ...[
            const Text(
              'No location available for this item right now.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.slate,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can still suggest or update this item location later.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.stone,
                height: 1.4,
              ),
            ),
          ],
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

  Widget _buildWriteReviewCard(BuildContext context) {
    final bool alreadyReviewed = _hasCurrentUserReviewed;

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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.rate_review_rounded,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rate this item',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alreadyReviewed
                      ? 'You already reviewed this item.'
                      : 'Give a quick rating and short review.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.stone,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: alreadyReviewed ? null : _openWriteReviewSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor:
              alreadyReviewed ? AppTheme.silver : AppTheme.accent,
              foregroundColor: AppTheme.snow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              alreadyReviewed ? 'Submitted' : 'Write',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
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
            'Recent reviews',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (_isReviewsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accent,
              ),
            )
          else if (_reviews.isEmpty)
            const Text(
              'No reviews yet. Be the first to rate this item.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.stone,
              ),
            )
          else
            ..._reviews.take(5).map(_buildReviewTile),
        ],
      ),
    );
  }

  Widget _buildReviewTile(ReviewModel review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.offWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.userName.isNotEmpty ? review.userName : 'User',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 16,
                      color: const Color(0xFFFF9F0A),
                    );
                  }),
                ),
              ],
            ),
            if (review.comment.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review.comment,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.slate,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

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
            'Loading more details.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.stone,
            ),
          ),
        ],
      ),
    );
  }

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

extension _StringFallbackExtension on String {
  String ifEmpty(String fallback) {
    return trim().isEmpty ? fallback : this;
  }
}