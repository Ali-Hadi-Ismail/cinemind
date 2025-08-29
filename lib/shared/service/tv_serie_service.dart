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
    print("🔍 Fetching TV series with ID: $id");
    print("🌐 URL: $url");

    try {
      final response = await http.get(url);
      print("📊 HTTP Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Response body: ${response.body}");

        final data = jsonDecode(response.body);

        // Optional: print keys in the JSON
        if (data is Map<String, dynamic>) {
          print("🗝️ JSON keys: ${data.keys.toList()}");
        } else {
          print("⚠️ Warning: response is not a JSON object");
        }

        final tvSerie = TvSerie.fromJson(data);
        print(
            "🎬 Parsed TV series name: ${tvSerie.name}, episodes: ${tvSerie.numberOfEpisodes}");
        return tvSerie;
      } else {
        print(
            "❌ Failed to fetch TV series. Status code: ${response.statusCode}");
        print("❌ Response body: ${response.body}");
        return null;
      }
    } catch (e, stackTrace) {
      print("💥 Exception while fetching TV series: $e");
      print(stackTrace);
      return null;
    }
  }

  Future<List<String>?> fetchTvImages(int seriesId) async {
    final url = Uri.parse('$baseUrl$seriesId/images?api_key=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // TMDb returns "backdrops" and "posters"
        final backdrops = (data['backdrops'] as List)
            .map((e) => e['file_path'] as String)
            .toList();

        final posters = (data['posters'] as List)
            .map((e) => e['file_path'] as String)
            .toList();

        // Merge lists (optional: remove duplicates)
        final images = [...backdrops, ...posters];
        return images.toSet().toList();
      } else {
        print('Failed to fetch images: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching TV images: $e');
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

  Future<List<TvSerie>?> getTrendingTvSeries({int page = 1}) async {
    final query = {
      'api_key': apiKey,
      'language': 'en-US',
      'page': '$page',
    };
    final endPoint = "/3/trending/tv/week";
    final url = Uri.https('api.themoviedb.org', endPoint, query);

    print('🔄 Fetching trending TV series...');
    print('📡 URL: $url');

    try {
      final response = await http.get(url);
      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Response data keys: ${data.keys}');
        print('📺 Results count: ${(data['results'] as List?)?.length ?? 0}');

        final results = (data['results'] as List?)
            ?.map((e) => TvSerie.fromJson(e))
            .toList();
        print('🎬 Parsed TV series count: ${results?.length ?? 0}');
        return results;
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        throw Exception(
            "Failed to fetch trending TV series: ${response.statusCode}");
      }
    } catch (e) {
      print("💥 Error fetching trending TV series: $e");
      return null;
    }
  }

  Future<List<TvSerie>> fetchSearchTV({
    required String query,
    int page = 1,
    int? firstAirDateYear,
    bool includeAdult = false,
    String language = 'en-US',
  }) async {
    final params = <String, String>{
      'api_key': apiKey,
      'query': query,
      'page': page.toString(),
      'language': language,
      'include_adult': includeAdult.toString(),
    };
    if (firstAirDateYear != null) {
      params['first_air_date_year'] = firstAirDateYear.toString();
    }

    final url = Uri.https('api.themoviedb.org', '/3/search/tv', params);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        return results
            .map((e) => TvSerie.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        // return empty list instead of null
        print('fetchSearchTV status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('fetchSearchTV error: $e');
      return [];
    }
  }
}
