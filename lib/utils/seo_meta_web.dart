// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:convert';

void updateSeoMeta({
  required String title,
  required String description,
  required String robots,
}) {
  html.document.title = title;

  _setMetaTagByName('description', description);
  _setMetaTagByName('robots', robots);
  _setMetaTagByProperty('og:title', title);
  _setMetaTagByProperty('og:description', description);
  _setMetaTagByProperty('og:type', 'website');
  _setMetaTagByName('twitter:card', 'summary_large_image');
  _setMetaTagByName('twitter:title', title);
  _setMetaTagByName('twitter:description', description);
  _setCanonicalLink();
}

void updateStructuredData({
  required String id,
  required Map<String, Object?> data,
}) {
  final head = html.document.head;
  if (head == null) {
    return;
  }

  final existing = head.querySelector('script#$id') as html.ScriptElement?;
  final payload = jsonEncode(_removeNulls(data));

  if (existing != null) {
    existing.text = payload;
    return;
  }

  final script = html.ScriptElement()
    ..id = id
    ..type = 'application/ld+json'
    ..text = payload;

  head.append(script);
}

void removeStructuredData(String id) {
  final head = html.document.head;
  if (head == null) {
    return;
  }

  head.querySelector('script#$id')?.remove();
}

Object? _removeNulls(Object? value) {
  if (value is Map<String, Object?>) {
    final cleaned = <String, Object?>{};
    for (final entry in value.entries) {
      final normalized = _removeNulls(entry.value);
      if (normalized != null) {
        cleaned[entry.key] = normalized;
      }
    }
    return cleaned;
  }

  if (value is List) {
    return value.map(_removeNulls).where((element) => element != null).toList();
  }

  return value;
}

void _setMetaTagByName(String name, String content) {
  final selector = 'meta[name="$name"]';
  final existing = html.document.head?.querySelector(selector) as html.MetaElement?;

  if (existing != null) {
    existing.content = content;
    return;
  }

  final meta = html.MetaElement()
    ..name = name
    ..content = content;
  html.document.head?.append(meta);
}

void _setMetaTagByProperty(String property, String content) {
  final selector = 'meta[property="$property"]';
  final existing = html.document.head?.querySelector(selector) as html.MetaElement?;

  if (existing != null) {
    existing.content = content;
    return;
  }

  final meta = html.MetaElement()
    ..setAttribute('property', property)
    ..content = content;
  html.document.head?.append(meta);
}

void _setCanonicalLink() {
  final head = html.document.head;
  if (head == null) {
    return;
  }

  final href = html.window.location.href;
  final existing = head.querySelector('link[rel="canonical"]') as html.LinkElement?;

  if (existing != null) {
    existing.href = href;
    return;
  }

  final link = html.LinkElement()
    ..rel = 'canonical'
    ..href = href;
  head.append(link);
}