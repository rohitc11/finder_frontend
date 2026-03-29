import 'package:flutter/material.dart';
import '../../models/bucket_list_item_model.dart';
import '../../services/bucket_list_service.dart';
import '../../theme/app_theme.dart';

/// Saved tab showing user's bookmarked items.
///
/// Responsibility:
/// - fetch saved items from backend
/// - render them in a clean list
/// - allow removing items from saved list
class SavedTab extends StatefulWidget {
  const SavedTab({super.key});

  @override
  State<SavedTab> createState() => SavedTabState();
}

class SavedTabState extends State<SavedTab> {
  /// Temporary hardcoded user for testing.
  ///
  /// Later this should come from login/session/local storage.
  static const String _testUserId = '69c9313bc495ce1fa3aeb8c5';

  /// Service responsible for bucket-list backend APIs.
  final BucketListService _bucketListService = BucketListService();

  /// Current saved items.
  List<BucketListItemModel> _savedItems = [];

  /// Loading state for initial fetch.
  bool _isLoading = true;

  /// Public refresh method used by parent screen when user opens Bucket List tab.
  void refreshSavedItems() {
    _loadSavedItems();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedItems();
  }

  /// Loads saved items from backend.
  Future<void> _loadSavedItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _bucketListService.fetchUserBucketList(
        userId: _testUserId,
      );

      if (!mounted) return;

      setState(() {
        _savedItems = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _savedItems = [];
        _isLoading = false;
      });
    }
  }

  /// Removes one saved item and updates the UI.
  Future<void> _removeSavedItem(BucketListItemModel item) async {
    final previousItems = List<BucketListItemModel>.from(_savedItems);

    // Optimistic UI update.
    setState(() {
      _savedItems.removeWhere((element) => element.itemId == item.itemId);
    });

    try {
      await _bucketListService.removeFromBucketList(
        userId: _testUserId,
        itemId: item.itemId,
      );
    } catch (e) {
      if (!mounted) return;

      // Revert if backend fails.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the static top header for the saved tab.
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

  /// Builds body based on current state.
  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState(context);
    }

    if (_savedItems.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildSavedItemsList();
  }

  /// Builds loading state while saved items are fetched.
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

  /// Builds empty state when no items are saved yet.
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

  /// Builds saved items list.
  Widget _buildSavedItemsList() {
    return RefreshIndicator(
      onRefresh: _loadSavedItems,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        itemCount: _savedItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _savedItems[index];

          return Container(
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
                GestureDetector(
                  onTap: () => _removeSavedItem(item),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}