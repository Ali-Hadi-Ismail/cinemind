import 'dart:convert';
import 'package:hive/hive.dart';

import 'package:cinemind/shared/service/search_service.dart';
import 'package:cinemind/model/movie.dart';
import 'package:cinemind/model/tv_series.dart';
import 'package:cinemind/model/person.dart';

class SearchRepo {
  final SearchService service;
  final Duration ttl;
  final Box _box = Hive.box('search');

  SearchRepo(this.service, {this.ttl = const Duration(hours: 1)});

  // ---------- Public API ----------

  Future<List<dynamic>> searchMulti(
    String query, {
    int page = 1,
    bool includeAdult = false,
    String language = "en-US",
  }) async {
    final key = 'multi|q:$query|p:$page|adult:$includeAdult|lang:$language';

    final cached = _readCache(key);
    if (cached != null && !_isExpired(cached)) {
      final list = List<Map<String, dynamic>>.from(cached['data'] as List);
      return list.map(_mapToSearchItem).toList();
    }

    final fresh = await service.fetchMultiSearch(
      query: query,
      page: page,
      includeAdult: includeAdult,
      language: language,
    );

    // Normalize to Map for cache
    final toStore = fresh.map<Map<String, dynamic>>((e) {
      if (e is Movie) return e.toJson()..['media_type'] = 'movie';
      if (e is TvSerie) return e.toJson()..['media_type'] = 'tv';
      if (e is Person) return e.toJson()..['media_type'] = 'person';
      if (e is Map<String, dynamic>) return e; // fallback
      // last resort: don’t crash cache on unknown item
      return {'media_type': 'unknown'};
    }).toList();

    _writeCache(key, toStore);
    return fresh;
  }

  Future<List<Movie>> searchMovies(
    String query, {
    int page = 1,
    int? year, // filter example
    bool includeAdult = false, // filter example
    String language = "en-US",
  }) async {
    final key =
        'movie|q:$query|p:$page|y:${year ?? "-"}|adult:$includeAdult|lang:$language';

    final cached = _readCache(key);
    if (cached != null && !_isExpired(cached)) {
      final list = List<Map<String, dynamic>>.from(cached['data'] as List);
      return list.map(Movie.fromJson).toList();
    }

    final fresh = await service.fetchSearchMovie(
      query: query,
      page: page,
      primaryReleaseYear: year,
      includeAdult: includeAdult,
    );

    _writeCache(key, fresh.map((m) => m.toJson()).toList());
    return fresh;
  }

  Future<List<TvSerie>> searchTv(
    String query, {
    int page = 1,
    int? firstAirDateYear, // filter example
    bool includeAdult = false, // filter example
    String language = "en-US",
  }) async {
    final key =
        'tv|q:$query|p:$page|y:${firstAirDateYear ?? "-"}|adult:$includeAdult|lang:$language';

    final cached = _readCache(key);
    if (cached != null && !_isExpired(cached)) {
      final list = List<Map<String, dynamic>>.from(cached['data'] as List);
      return list.map(TvSerie.fromJson).toList();
    }

    final fresh = await service.fetchSearchTV(
      query: query,
      page: page,
      firstAirDateYear: firstAirDateYear,
      includeAdult: includeAdult,
      language: language,
    );

    _writeCache(key, fresh.map((t) => t.toJson()).toList());
    return fresh;
  }

  // ---------- Helpers ----------

  dynamic _mapToSearchItem(Map<String, dynamic> json) {
    switch (json['media_type']) {
      case 'movie':
        return Movie.fromJson(json);
      case 'tv':
        return TvSerie.fromJson(json);
      case 'person':
        return Person.fromJson(json);
      default:
        return json; // unknown, keep as Map
    }
    // Note: Movie/TvSerie/Person should each have toJson() and fromJson()
  }

  Map<String, dynamic>? _readCache(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;

    final decoded = (raw is String) ? jsonDecode(raw) : raw;
    if (decoded is! Map<String, dynamic>) return null;
    return decoded;
  }

  bool _isExpired(Map<String, dynamic> cached) {
    final ts = cached['timestamp'] as String?;
    if (ts == null) return true;
    final dt = DateTime.tryParse(ts);
    if (dt == null) return true;
    return DateTime.now().difference(dt) > ttl;
  }

  void _writeCache(String key, List<Map<String, dynamic>> data) {
    final payload = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _box.put(key, jsonEncode(payload));
  }
}
