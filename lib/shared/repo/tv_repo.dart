import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:cinemind/model/tv_series.dart';
import 'package:cinemind/model/season.dart';
import 'package:cinemind/model/episode.dart';
import '../service/tv_serie_service.dart';

class TvRepo {
  final TvSerieService service;
  final Box cacheBox;

  // In-flight requests dedupe
  final Map<String, Future<dynamic>> _inflight = {};

  TvRepo({required this.service, required this.cacheBox});

  // -------------------- Get TV Series by ID --------------------
  Future<TvSerie?> getTvSeries(int id) async {
    final key = 'series_$id';

    // 1️⃣ Check cache
    if (cacheBox.containsKey(key)) {
      final cached = cacheBox.get(key);
      return TvSerie.fromJson(jsonDecode(cached));
    }

    // 2️⃣ Fetch from API
    final series = await service.fetchTvSerieByID(id);
    if (series != null) {
      cacheBox.put(key, jsonEncode(series.toJson()));
    }
    return series;
  }

  // -------------------- Get Season --------------------
  Future<Season?> getSeason(int seriesId, int seasonNumber) async {
    final key = 'season_${seriesId}_$seasonNumber';

    if (cacheBox.containsKey(key)) {
      final cached = cacheBox.get(key);
      return Season.fromJson(jsonDecode(cached));
    }

    final season = await service.fetchTvSerieSeason(seriesId, seasonNumber);
    if (season != null) {
      cacheBox.put(key, jsonEncode(season.toJson()));
    }
    return season;
  }

  // -------------------- Get Episode --------------------
  Future<Episode?> getEpisode(
      int seriesId, int seasonNumber, int episodeNumber) async {
    final key = 'episode_${seriesId}_${seasonNumber}_$episodeNumber';

    if (cacheBox.containsKey(key)) {
      final cached = cacheBox.get(key);
      return Episode.fromJson(jsonDecode(cached));
    }

    final episode =
        await service.fetchEpisode(seriesId, seasonNumber, episodeNumber);
    if (episode != null) {
      cacheBox.put(key, jsonEncode(episode.toJson()));
    }
    return episode;
  }

  // -------------------- Get Popular List --------------------
  Future<List<TvSerie>?> getPopular({int page = 1}) async {
    final key = 'popular_page_$page';

    if (cacheBox.containsKey(key)) {
      final cached = cacheBox.get(key);
      if (cached is List) {
        return cached
            .map((e) => TvSerie.fromJson(jsonDecode(e.toString())))
            .toList();
      }
    }

    final list = await service.getPopularTvSeries(page: page);
    if (list != null && list.isNotEmpty) {
      await cacheBox.put(key, list.map((e) => jsonEncode(e.toJson())).toList());
    }
    return list;
  }

  // -------------------- Get Top Rated List --------------------
  Future<List<TvSerie>?> getTopRated({int page = 1}) async {
    final key = 'toprated_page_$page';

    if (cacheBox.containsKey(key)) {
      final cached = cacheBox.get(key);
      if (cached is List) {
        return cached
            .map((e) => TvSerie.fromJson(jsonDecode(e.toString())))
            .toList();
      }
    }

    final list = await service.getTopRatedTvSeries(page: page);
    if (list != null && list.isNotEmpty) {
      await cacheBox.put(key, list.map((e) => jsonEncode(e.toJson())).toList());
    }
    return list;
  }

  // -------------------- Get On Air List --------------------
  Future<List<TvSerie>?> getOnTheAir({int page = 1}) async {
    final key = 'onair_page_$page';

    if (cacheBox.containsKey(key)) {
      final cached = cacheBox.get(key);
      if (cached is List) {
        return cached
            .map((e) => TvSerie.fromJson(jsonDecode(e.toString())))
            .toList();
      }
    }

    final list = await service.getOnTheAirTvSeries(page: page);
    if (list != null && list.isNotEmpty) {
      await cacheBox.put(key, list.map((e) => jsonEncode(e.toJson())).toList());
    }
    return list;
  }

  Future<List<TvSerie>?> getTrendingTvSeries() async {
    final key = 'trending_tv_series';

    // Return cached list if present
    if (cacheBox.containsKey(key)) {
      final cached = cacheBox.get(key);
      if (cached is List) {
        return cached
            .map((e) => TvSerie.fromJson(jsonDecode(e.toString())))
            .toList();
      }
    }

    // Deduplicate in-flight fetches
    if (_inflight.containsKey(key)) {
      return await _inflight[key] as List<TvSerie>?;
    }

    final fetchFuture = service.getTrendingTvSeries().then((list) async {
      if (list != null && list.isNotEmpty) {
        await cacheBox.put(
            key, list.map((e) => jsonEncode(e.toJson())).toList());
      }
      _inflight.remove(key);
      return list;
    });

    _inflight[key] = fetchFuture;
    return await fetchFuture;
  }
}
