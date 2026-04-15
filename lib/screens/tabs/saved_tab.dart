import 'package:flutter/material.dart';

import '../../config/user_session.dart';
import '../../models/bucket_list_item_model.dart';
import '../../models/search_result_model.dart';
import '../../services/bucket_list_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../item_detail_screen.dart';

class SavedTab extends StatefulWidget {
  final bool showInternalHeader;

  const SavedTab({
    super.key,
    this.showInternalHeader = true,
  });

  @override
  State<SavedTab> createState() => SavedTabState();
}

class SavedTabState extends State<SavedTab> {
  final BucketListService _bucketListService = BucketListService();

  List<BucketListItemModel> _savedItems = [];
  bool _isLoading = true;

  void refreshSavedItems() {
    if (UserSession.isLoggedIn) {
      _loadSavedItems();
    } else {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    if (UserSession.isLoggedIn) {
      _loadSavedItems();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadSavedItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _bucketListService.fetchSavedItems();

      if (!mounted) return;

      setState(() {
        _savedItems = items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _savedItems = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _openLogin() async {
    final bool? loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );

    if (loggedIn == true && mounted) {
      await _loadSavedItems();
    }
  }

  Future<void> _removeSavedItem(BucketListItemModel item) async {
    final previousItems = List<BucketListItemModel>.from(_savedItems);

    setState(() {
      _savedItems.removeWhere((element) => element.itemId == item.itemId);
    });

    try {
      await _bucketListService.removeFromBucketList(item.itemId);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _savedItems = previousItems;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not remove saved item. Please try again.'),
        ),
      );
    }
  }

  void _openSavedItemDetail(BucketListItemModel item) {
    final summary = SearchResultModel(
      itemId: item.itemId,
      itemName: item.itemName,
      restaurantId: '',
      restaurantName: '',
      city: item.city,
      areaName: item.areaName,
      avgItemRating: null,
      ratingCount: null,
      likeCount: 0,
      likedByCurrentUser: false,
      distanceInKm: null,
      isBookmarked: true,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(summary: summary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!UserSession.isLoggedIn) {
      return _buildGuestPreview(context);
    }

    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: SafeArea(
        child: Column(
          children: [
            if (widget.showInternalHeader) _buildHeader(context),
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestPreview(BuildContext context) {
    final previewItems = [
      const _PreviewBookmark(
        itemName: 'Cheese Dabeli',
        areaName: 'Navrangpura',
        city: 'Ahmedabad',
      ),
      const _PreviewBookmark(
        itemName: 'Pani Puri',
        areaName: 'Law Garden',
        city: 'Ahmedabad',
      ),
      const _PreviewBookmark(
        itemName: 'Butter Pav Bhaji',
        areaName: 'Juhu',
        city: 'Mumbai',
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showInternalHeader) _buildHeader(context),
              if (widget.showInternalHeader) const SizedBox(height: 12),
              const Text(
                'Preview how your saved items will look after login.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.stone,
                ),
              ),
              const SizedBox(height: 16),
              ...previewItems.map(
                    (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: _openLogin,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.snow,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.shadowXs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.offWhite,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.itemName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.areaName}, ${item.city}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.pebble,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.bookmark_rounded,
                            color: AppTheme.accent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
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
                      'Save dishes you want to try',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Login to build your personal bucket list and access it anytime.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.stone,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _openLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: AppTheme.snow,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Login to save items',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Text(
            'Bucket List',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState(context);
    }

    if (_savedItems.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildSavedItemsList();
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.accent,
            strokeWidth: 2,
          ),
          const SizedBox(height: 14),
          Text(
            'Loading saved items...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.stone,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bookmark_border_rounded,
              size: 46,
              color: AppTheme.pebble,
            ),
            const SizedBox(height: 12),
            Text(
              'Your bucket list is empty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save food items you want to try and they will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.stone,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedItemsList() {
    return RefreshIndicator(
      onRefresh: _loadSavedItems,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        itemCount: _savedItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _savedItems[index];

          return InkWell(
            onTap: () => _openSavedItemDetail(item),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.snow,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.shadowXs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.offWhite,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [item.areaName, item.city]
                              .where((e) => e.trim().isNotEmpty)
                              .join(', '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.pebble,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _removeSavedItem(item),
                    child: const Icon(
                      Icons.bookmark_rounded,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PreviewBookmark {
  final String itemName;
  final String areaName;
  final String city;

  const _PreviewBookmark({
    required this.itemName,
    required this.areaName,
    required this.city,
  });
}