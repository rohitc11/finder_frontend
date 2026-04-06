import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevLoginDefaults {
  static const String _assetPath = 'assets/.finder.local.json';
  static const String _savedIdentifierKey = 'dev_login_identifier';
  static const String _savedPasswordKey = 'dev_login_password';
  static const String _emailKey = 'FINDER_LOGIN_EMAIL';
  static const String _passwordKey = 'FINDER_LOGIN_PASSWORD';

  static Future<LoginPrefill> load() async {
    if (!kDebugMode) {
      return const LoginPrefill();
    }

    final prefs = await SharedPreferences.getInstance();
    final savedIdentifier = (prefs.getString(_savedIdentifierKey) ?? '').trim();
    final savedPassword = (prefs.getString(_savedPasswordKey) ?? '').trim();
    final localConfig = await _loadAssetConfig();

    final localIdentifier = _readString(localConfig, _emailKey);
    final localPassword = _readString(localConfig, _passwordKey);

    return LoginPrefill(
      identifier: localIdentifier.isNotEmpty ? localIdentifier : savedIdentifier,
      password: localPassword.isNotEmpty ? localPassword : savedPassword,
    );
  }

  static Future<void> saveLastUsed({
    required String identifier,
    required String password,
  }) async {
    if (!kDebugMode) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedIdentifierKey, identifier.trim());
    await prefs.setString(_savedPasswordKey, password.trim());
  }

  static Future<Map<String, dynamic>?> _loadAssetConfig() async {
    try {
      final content = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(content);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static String _readString(Map<String, dynamic>? config, String key) {
    final value = config?[key];
    if (value is String) {
      return value.trim();
    }

    return '';
  }
}

class LoginPrefill {
  final String identifier;
  final String password;

  const LoginPrefill({
    this.identifier = '',
    this.password = '',
  });
}