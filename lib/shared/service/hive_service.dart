import 'package:hive/hive.dart';

import '../../model/movie.dart';

class HiveService {
  final Box box;
  HiveService(this.box);

// get movie from cache
  Future<List<Movie>> getMovies(String key) async {
    final data = box.get(key);
    if (data != null) {
      return (data as List)
          .map((e) => Movie.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<void> saveMovies(String key, List<Movie> movies) async {
    final jsonData = movies.map((e) => e.toJson()).toList();
    await box.put(key, jsonData);
    await box.put('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  int? getCacheTimestamp(String key) => box.get('${key}_timestamp');

  bool isCacheValid(String key, Duration maxAge) {
    final ts = getCacheTimestamp(key);
    if (ts == null) return false;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(cachedAt) < maxAge;
  }
}
