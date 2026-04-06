import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/search_result_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/item_detail_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String saved = '/saved';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';

  static String tabPath(int index) {
    switch (index) {
      case 1:
        return search;
      case 2:
        return saved;
      case 3:
        return profile;
      case 0:
      default:
        return home;
    }
  }

  static String itemPath({
    required String itemId,
    String? itemName,
  }) {
    return '/items/${slugify(itemName ?? itemId)}/$itemId';
  }

  static String itemPathFromSummary(SearchResultModel summary) {
    return itemPath(
      itemId: summary.itemId,
      itemName: summary.itemName,
    );
  }

  static String slugify(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    return slug.isEmpty ? 'item' : slug;
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: HomeScreen(initialIndex: 0),
        ),
      ),
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: HomeScreen(initialIndex: 1),
        ),
      ),
      GoRoute(
        path: AppRoutes.saved,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: HomeScreen(initialIndex: 2),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) => const NoTransitionPage<void>(
          child: HomeScreen(initialIndex: 3),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/items/:slug/:itemId',
        builder: (context, state) {
          final extra = state.extra;
          final summary = extra is SearchResultModel ? extra : null;

          return ItemDetailScreen(
            itemId: state.pathParameters['itemId'],
            summary: summary,
          );
        },
      ),
      GoRoute(
        path: '/items/:itemId',
        redirect: (context, state) {
          final itemId = state.pathParameters['itemId'];
          if (itemId == null || itemId.isEmpty) {
            return AppRoutes.home;
          }
          return AppRoutes.itemPath(itemId: itemId);
        },
      ),
    ],
  );

  static void goHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  static void goTab(BuildContext context, int index) {
    context.go(AppRoutes.tabPath(index));
  }

  static Future<bool?> openLogin(BuildContext context) {
    return context.push<bool>(AppRoutes.login);
  }

  static Future<bool?> openRegister(BuildContext context) {
    return context.push<bool>(AppRoutes.register);
  }

  static Future<void> openItem(
    BuildContext context,
    SearchResultModel summary,
  ) {
    return context.push<void>(
      AppRoutes.itemPathFromSummary(summary),
      extra: summary,
    );
  }
}