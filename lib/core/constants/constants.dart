class AppConstants {
  static const baseUrl = 'http://192.168.20.142:8080/api';
  static const baseImageUrl = 'http://192.168.20.142:8080/uploads/';

  /// Constructs a complete image URL - handles cases where path already contains /uploads/
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    // If the path already starts with http, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // If path starts with /uploads/, prepend only the base domain (no /uploads/)
    if (imagePath.startsWith('/uploads/')) {
      return 'http://192.168.20.142:8080$imagePath';
    }

    // Otherwise, use the full baseImageUrl
    // Remove leading slash to avoid double slashes
    final cleanPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;
    return '$baseImageUrl$cleanPath';
  }
}
