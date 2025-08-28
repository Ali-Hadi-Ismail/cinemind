import 'package:hive/hive.dart';
import '../../model/movie.dart';

class HiveService {
  final Box box;
  HiveService(this.box);

  // ✅ Get movies from cache safely
  Future<List<Movie>> getMovies(String key) async {
    final data = box.get(key);
    if (data != null && data is List) {
      return data.map((e) {
        if (e is Map) {
          // Convert dynamic map to Map<String, dynamic> safely
          return Movie.fromJson(Map<String, dynamic>.from(e));
        } else {
          throw Exception("Invalid cached data for key $key");
        }
      }).toList();
    }
    return [];
  }

  // Save movies to cache
  Future<void> saveMovies(String key, List<Movie> movies) async {
    final jsonData = movies.map((e) => e.toJson()).toList();
    await box.put(key, jsonData);
    await box.put('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  // Get timestamp of cached data
  int? getCacheTimestamp(String key) => box.get('${key}_timestamp');

  // Check if cache is still valid
  bool isCacheValid(String key, Duration maxAge) {
    final ts = getCacheTimestamp(key);
    if (ts == null) return false;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(cachedAt) < maxAge;
  }
}
