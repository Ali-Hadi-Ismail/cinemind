import 'dart:convert';

import 'package:cinemind/model/episode.dart';
import 'package:cinemind/model/season.dart';
import 'package:cinemind/model/tv_series.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TvSerieService {
  final String baseUrl = "https://api.themoviedb.org/3/tv/";
  final String apiKey = dotenv.env['TMDB_API_KEY']!;
  Future<TvSerie?> fetchTvSerieByID(int id) async {
    final url = Uri.parse("$baseUrl$id?api_key=$apiKey");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TvSerie.fromJson(data);
      } else {
        throw Exception("Failed to fetch season :${response.statusCode} ");
      }
    } catch (e) {
      return null;
    }
  }

  Future<Season?> fetchTvSerieSeason(int serieId, int seasonNumber) async {
    try {
/*       final String seasonUrl =
          "$baseUrl$serieId/season/$seasonNumber?api_Key=$apiKey"; */
//      final url = Uri.parse(seasonUrl);
      final url = Uri.https(
        "api.themoviedb.org",
        "/3/tv/$serieId/season/$seasonNumber",
        {
          "api_key": apiKey,
        },
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Season.fromJson(data);
      } else {
        throw Exception("Failed to fetch season :${response.statusCode} ");
      }
    } catch (e) {
      print("Error fetching season $seasonNumber of series $serieId: $e");
      return null;
    }
  }

  Future<Episode?> fetchEpisode(
      int serieId, int seasonNumber, int episodeNumber) async {
    try {
      final url = Uri.https(
          "api.themoviedb.org",
          "/3/tv/$serieId/season/$seasonNumber/episode/$episodeNumber",
          {'api_key': apiKey, 'language': 'en-US'});

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Episode.fromJson(data);
      } else {
        throw Exception("Please review code");
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<TvSerie>?> getPopularTvSeries({int page = 1}) async {
    final query = {'api_key': apiKey, 'language': 'en-US', 'page': '$page'};
    String endPoint = "/3/tv/popular";
    final url = Uri.https('api.themoviedb.org', endPoint, query);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] == null) {
          print("No results found in the response");
          return null;
        }
        return (data['results'] as List)
            .map((e) => TvSerie.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        throw Exception(
            "Failed to fetch popular TV series: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching popular TV series: $e");
      return null;
    }
  }

  Future<List<TvSerie>?> getTopRatedTvSeries({int page = 1}) async {
    final query = {
      'api_key': apiKey,
      'language': 'en-US',
      'page': '$page',
    };
    final endPoint = "/3/tv/top_rated";
    final url = Uri.https('api.themoviedb.org', endPoint, query);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List)
            .map((e) => TvSerie.fromJson(e))
            .toList();
      } else {
        throw Exception(
            "Failed to fetch top-rated TV series: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching top-rated TV series: $e");
      return null;
    }
  }

  Future<List<TvSerie>?> getOnTheAirTvSeries({int page = 1}) async {
    final query = {
      'api_key': apiKey,
      'language': 'en-US',
      'page': '$page',
    };
    final endPoint = "/3/tv/on_the_air";
    final url = Uri.https('api.themoviedb.org', endPoint, query);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List)
            .map((e) => TvSerie.fromJson(e))
            .toList();
      } else {
        throw Exception(
            "Failed to fetch on-air TV series: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching on-air TV series: $e");
      return null;
    }
  }
}
