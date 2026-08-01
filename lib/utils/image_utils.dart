const propertyImageBaseUrl = 'https://c7b7e222e9fb29445b351d0712389bee.ctonew.app';

/// Resolves image paths stored as site-relative URLs while preserving data and
/// already absolute URLs.
String resolvePropertyImageUrl(String path) {
  if (path.startsWith('data:') || path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }
  if (path.startsWith('/')) return '$propertyImageBaseUrl$path';
  return path;
}

/// Returns whether [path] points to a video file rather than an image.
bool isVideoPath(String path) {
  final pathWithoutQuery = path.split('?').first.split('#').first;
  return RegExp(r'\.(mp4|mov|webm|m4v)$', caseSensitive: false)
      .hasMatch(pathWithoutQuery);
}
