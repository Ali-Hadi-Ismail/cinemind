import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:cinemind/model/tv_series.dart';
import 'package:cinemind/model/season.dart';
import 'package:cinemind/model/episode.dart';
import '../service/tv_serie_service.dart';

class TvRepo {
  final TvSerieService service;
  final Box cacheBox = Hive.box('tv_cache');

  final Map<String, Future<dynamic>> _inflight = {};

  // Cache expiry time (30 minutes for lists, longer for individual items)
  static const Duration _listCacheExpiry = Duration(minutes: 30);
  static const Duration _itemCacheExpiry = Duration(hours: 24);

  TvRepo({
    required this.service,
  });

  // -------------------- TV Series by ID --------------------
  Future<TvSerie?> getTvSeries(int id) async {
    final key = 'series_$id';

    if (_isCacheValid(key, _itemCacheExpiry)) {
      final cached = cacheBox.get(key);
      if (cached is Map && cached.containsKey('data')) {
        return TvSerie.fromJson(jsonDecode(cached['data'] as String));
      }
    }

    final series = await _dedupedFetch(key, () => service.fetchTvSerieByID(id));
    if (series != null) {
      _setCacheWithTimestamp(key, jsonEncode(series.toJson()));
    }
    return series;
  }

  // -------------------- Season --------------------
  Future<Season?> getSeason(int seriesId, int seasonNumber) async {
    final key = 'season_${seriesId}_$seasonNumber';

    if (_isCacheValid(key, _itemCacheExpiry)) {
      final cached = cacheBox.get(key);
      if (cached is Map && cached.containsKey('data')) {
        return Season.fromJson(jsonDecode(cached['data'] as String));
      }
    }

    final season = await _dedupedFetch(
        key, () => service.fetchTvSerieSeason(seriesId, seasonNumber));
    if (season != null) {
      _setCacheWithTimestamp(key, jsonEncode(season.toJson()));
    }
    return season;
  }

  // -------------------- Episode --------------------
  Future<Episode?> getEpisode(
      int seriesId, int seasonNumber, int episodeNumber) async {
    final key = 'episode_${seriesId}_${seasonNumber}_$episodeNumber';

    if (_isCacheValid(key, _itemCacheExpiry)) {
      final cached = cacheBox.get(key);
      if (cached is Map && cached.containsKey('data')) {
        return Episode.fromJson(jsonDecode(cached['data'] as String));
      }
    }

    final episode = await _dedupedFetch(
        key, () => service.fetchEpisode(seriesId, seasonNumber, episodeNumber));
    if (episode != null) {
      _setCacheWithTimestamp(key, jsonEncode(episode.toJson()));
    }
    return episode;
  }

  // -------------------- Lists with Proper Pagination --------------------
  Future<List<TvSerie>?> getPopular({int page = 1}) => _getListWithPagination(
      'popular', page, () => service.getPopularTvSeries(page: page));

  Future<List<TvSerie>?> getTopRated({int page = 1}) => _getListWithPagination(
      'toprated', page, () => service.getTopRatedTvSeries(page: page));

  Future<List<TvSerie>?> getOnTheAir({int page = 1}) => _getListWithPagination(
      'onair', page, () => service.getOnTheAirTvSeries(page: page));

  Future<List<TvSerie>?> getTrendingTvSeries({int page = 1}) {
    print('🗄️ Repo: getTrendingTvSeries() called for page $page');
    return _getListWithPagination('trending_tv_series', page, () {
      print(
          '🗄️ Repo: Lambda function called - about to call service for page $page');
      return service.getTrendingTvSeries(page: page);
    });
  }

  // -------------------- Helpers --------------------
  Future<T> _dedupedFetch<T>(String key, Future<T> Function() fetcher) async {
    if (_inflight.containsKey(key)) {
      final result = await _inflight[key] as T;
      return result;
    }

    final future = fetcher().whenComplete(() {
      _inflight.remove(key);
    });

    _inflight[key] = future;
    final result = await future;
    return result;
  }

  /// Fixed method for handling paginated lists
  Future<List<TvSerie>?> _getListWithPagination(String listType, int page,
      Future<List<TvSerie>?> Function() fetcher) async {
    // Create a unique key for each page
    final key = '${listType}_page_$page';
    print('🗄️ Repo: Checking cache for key: $key');

    // Check if we have valid cached data for this specific page
    if (_isCacheValid(key, _listCacheExpiry)) {
      final cached = cacheBox.get(key);
      if (cached is Map &&
          cached.containsKey('data') &&
          cached['data'] is List) {
        try {
          final List<dynamic> cachedData = cached['data'] as List<dynamic>;
          final result = cachedData.map((e) {
            return TvSerie.fromJson(jsonDecode(e as String));
          }).toList();
          print(
              '🗄️ Repo: Returning ${result.length} cached items for page $page');
          return result;
        } catch (e) {
          print('❌ Repo: Error parsing cached data: $e');
          await cacheBox.delete(key);
        }
      }
    }

    print('🗄️ Repo: Fetching fresh data for page $page');
    // Fetch fresh data
    final list = await _dedupedFetch(key, fetcher);

    if (list != null && list.isNotEmpty) {
      try {
        final cacheData = list.map((e) => jsonEncode(e.toJson())).toList();
        _setCacheWithTimestamp(key, cacheData);
        print('🗄️ Repo: Cached ${list.length} items for page $page');
      } catch (e) {
        print('❌ Repo: Error caching data: $e');
      }
    } else {
      print('🗄️ Repo: No data received for page $page');
    }

    return list;
  }

  /// Check if cached data is still valid
  bool _isCacheValid(String key, Duration maxAge) {
    if (!cacheBox.containsKey(key)) return false;

    final cached = cacheBox.get(key);
    if (cached is! Map || !cached.containsKey('timestamp')) return false;

    final timestamp = cached['timestamp'] as int;
    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final isValid = DateTime.now().difference(cachedTime) < maxAge;

    if (!isValid) {
      print('🗄️ Repo: Cache expired for key: $key');
      cacheBox.delete(key);
    }

    return isValid;
  }

  /// Set cache data with timestamp
  void _setCacheWithTimestamp(String key, dynamic data) {
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    cacheBox.put(key, cacheEntry);
  }

  // -------------------- Images --------------------
  final Map<String, Future<List<String>?>> _inflightImages = {};

  Future<List<String>> getTvImages(int seriesId) async {
    final key = 'images_$seriesId';

    // Check cache with timestamp
    if (_isCacheValid(key, _itemCacheExpiry)) {
      final cached = cacheBox.get(key);
      if (cached is Map &&
          cached.containsKey('data') &&
          cached['data'] is List) {
        return (cached['data'] as List).map((e) => e.toString()).toList();
      }
    }

    // Deduplicate in-flight fetches
    if (_inflightImages.containsKey(key)) {
      return await _inflightImages[key] ?? [];
    }

    // Fetch from API
    final fetchFuture = service.fetchTvImages(seriesId).then((list) async {
      final images = list ?? [];
      if (images.isNotEmpty) {
        _setCacheWithTimestamp(key, images);
      }
      _inflightImages.remove(key);
      return images;
    });

    _inflightImages[key] = fetchFuture;
    return await fetchFuture;
  }

  // -------------------- Cache Management --------------------

  /// Clear all cached data
  Future<void> clearCache() async {
    await cacheBox.clear();
    _inflight.clear();
    _inflightImages.clear();
    print('🗄️ Repo: All cache cleared');
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final keys = cacheBox.keys.toList();
    int deletedCount = 0;

    for (final key in keys) {
      final cached = cacheBox.get(key);
      if (cached is Map && cached.containsKey('timestamp')) {
        final timestamp = cached['timestamp'] as int;
        final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final age = DateTime.now().difference(cachedTime);

        // Use different expiry times based on key type
        final maxAge = key.toString().contains('page_')
            ? _listCacheExpiry
            : _itemCacheExpiry;

        if (age > maxAge) {
          await cacheBox.delete(key);
          deletedCount++;
        }
      }
    }

    print('🗄️ Repo: Cleared $deletedCount expired cache entries');
  }
}
