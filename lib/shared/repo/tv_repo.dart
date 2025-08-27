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

  TvRepo({
    required this.service,
  });

  // -------------------- TV Series by ID --------------------
  Future<TvSerie?> getTvSeries(int id) async {
    final key = 'series_$id';

    if (cacheBox.containsKey(key)) {
      final cached = cacheBox.get(key);
      return TvSerie.fromJson(jsonDecode(cached as String));
    }

    final series = await _dedupedFetch(key, () => service.fetchTvSerieByID(id));
    if (series != null) {
      cacheBox.put(key, jsonEncode(series.toJson()));
    }
    return series;
  }

  // -------------------- Season --------------------
  Future<Season?> getSeason(int seriesId, int seasonNumber) async {
    final key = 'season_${seriesId}_$seasonNumber';
    if (cacheBox.containsKey(key)) {
      final cached = cacheBox.get(key);
      return Season.fromJson(jsonDecode(cached as String));
    }

    final season = await _dedupedFetch(
        key, () => service.fetchTvSerieSeason(seriesId, seasonNumber));
    if (season != null) {
      cacheBox.put(key, jsonEncode(season.toJson()));
    }
    return season;
  }

  // -------------------- Episode --------------------
  Future<Episode?> getEpisode(
      int seriesId, int seasonNumber, int episodeNumber) async {
    final key = 'episode_${seriesId}_${seasonNumber}_$episodeNumber';
    if (cacheBox.containsKey(key)) {
      final cached = cacheBox.get(key);
      return Episode.fromJson(jsonDecode(cached as String));
    }

    final episode = await _dedupedFetch(
        key, () => service.fetchEpisode(seriesId, seasonNumber, episodeNumber));
    if (episode != null) {
      cacheBox.put(key, jsonEncode(episode.toJson()));
    }
    return episode;
  }

  // -------------------- Lists --------------------
  Future<List<TvSerie>?> getPopular({int page = 1}) => _getList(
      'popular_page_$page', () => service.getPopularTvSeries(page: page));

  Future<List<TvSerie>?> getTopRated({int page = 1}) => _getList(
      'toprated_page_$page', () => service.getTopRatedTvSeries(page: page));

  Future<List<TvSerie>?> getOnTheAir({int page = 1}) => _getList(
      'onair_page_$page', () => service.getOnTheAirTvSeries(page: page));

  Future<List<TvSerie>?> getTrendingTvSeries() =>
      _getList('trending_tv_series', () => service.getTrendingTvSeries());

  // -------------------- Helpers --------------------
  Future<T> _dedupedFetch<T>(String key, Future<T> Function() fetcher) async {
    if (_inflight.containsKey(key)) return await _inflight[key] as T;
    final future = fetcher().whenComplete(() => _inflight.remove(key));
    _inflight[key] = future;
    return await future;
  }

  Future<List<TvSerie>?> _getList(
      String key, Future<List<TvSerie>?> Function() fetcher) async {
    if (cacheBox.containsKey(key)) {
      final cached = cacheBox.get(key);
      if (cached is List) {
        return cached
            .map((e) => TvSerie.fromJson(jsonDecode(e as String)))
            .toList();
      }
    }

    final list = await _dedupedFetch(key, fetcher);
    if (list != null && list.isNotEmpty) {
      cacheBox.put(key, list.map((e) => jsonEncode(e.toJson())).toList());
    }
    return list;
  }

  final Map<String, Future<List<String>?>> _inflightImages = {};
  Future<List<String>> getTvImages(int seriesId) async {
    final key = 'images_$seriesId';

    // 1️⃣ Check cache
    if (cacheBox.containsKey(key)) {
      final cached = cacheBox.get(key);
      if (cached is List) {
        return cached.map((e) => e.toString()).toList();
      }
    }

    // 2️⃣ Deduplicate in-flight fetches
    if (_inflightImages.containsKey(key)) {
      return await _inflightImages[key] ?? [];
    }

    // 3️⃣ Fetch from API
    final fetchFuture = service.fetchTvImages(seriesId).then((list) async {
      final images = list ?? [];
      if (images.isNotEmpty) {
        await cacheBox.put(key, images); // save list of strings directly
      }
      _inflightImages.remove(key);
      return images;
    });

    _inflightImages[key] = fetchFuture;
    return await fetchFuture;
  }
}
