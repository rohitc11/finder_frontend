import 'seo_meta_stub.dart' if (dart.library.html) 'seo_meta_web.dart' as impl;

void updateSeoMeta({
  required String title,
  required String description,
  String robots = 'index,follow',
}) {
  impl.updateSeoMeta(
    title: title,
    description: description,
    robots: robots,
  );
}

void updateStructuredData({
  required String id,
  required Map<String, Object?> data,
}) {
  impl.updateStructuredData(
    id: id,
    data: data,
  );
}

void removeStructuredData(String id) {
  impl.removeStructuredData(id);
}