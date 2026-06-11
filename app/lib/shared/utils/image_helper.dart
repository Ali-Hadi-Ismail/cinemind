class ImageHelper {
  // Base URLs
  static const String posterBaseUrl = "https://image.tmdb.org/t/p/w500";
  static const String backdropBaseUrl = "https://image.tmdb.org/t/p/w780";

  /// Returns full URL for a poster
  static String poster(String? path) {
    if (path == null || path.isEmpty) {
      return "https://via.placeholder.com/500x750?text=No+Image"; // fallback
    }
    return "$posterBaseUrl$path";
  }

  /// Returns full URL for a backdrop
  static String backdrop(String? path) {
    if (path == null || path.isEmpty) {
      return "https://via.placeholder.com/780x439?text=No+Image"; // fallback
    }
    return "$backdropBaseUrl$path";
  }
}
