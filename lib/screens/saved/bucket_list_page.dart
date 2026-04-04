import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../tabs/saved_tab.dart';

class BucketListPage extends StatelessWidget {
  const BucketListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      appBar: AppBar(
        backgroundColor: AppTheme.fog,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        title: const Text(
          'Bucket List',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: const SavedTab(showInternalHeader: false),
    );
  }
}