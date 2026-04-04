import 'package:flutter/material.dart';

import '../../models/admin_suggestion_model.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'pending_suggestion_detail_screen.dart';

/// Admin screen showing all pending suggestions.
///
/// UX:
/// - lightweight list
/// - tap a card to inspect full details before moderation
class PendingSuggestionsScreen extends StatefulWidget {
  const PendingSuggestionsScreen({super.key});

  @override
  State<PendingSuggestionsScreen> createState() =>
      _PendingSuggestionsScreenState();
}

class _PendingSuggestionsScreenState extends State<PendingSuggestionsScreen> {
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  List<AdminSuggestionModel> _items = [];

  @override
  void initState() {
    super.initState();
    _loadPendingItems();
  }

  Future<void> _loadPendingItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _adminService.fetchPendingSuggestions();

      if (!mounted) return;

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _items = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _openDetail(AdminSuggestionModel item) async {
    final bool? changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PendingSuggestionDetailScreen(item: item),
      ),
    );

    if (changed == true && mounted) {
      await _loadPendingItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      appBar: AppBar(
        backgroundColor: AppTheme.fog,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        title: const Text(
          'Review Items',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accent,
          strokeWidth: 2,
        ),
      )
          : _items.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadPendingItems,
        color: AppTheme.accent,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _items[index];
            return InkWell(
              onTap: () => _openDetail(item),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.snow,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.shadowXs,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.offWhite,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.pending_actions_rounded,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                            item.restaurantName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.slate,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            [
                              item.areaName,
                              item.city,
                            ].where((e) => e.trim().isNotEmpty).join(', '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.stone,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.silver,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 46,
              color: AppTheme.pebble,
            ),
            SizedBox(height: 12),
            Text(
              'No pending items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'All suggestions are reviewed for now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.stone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}