import 'dart:convert';
import 'package:cinemind/model/tv_series.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../model/person.dart';
import '../../model/movie.dart';

class SearchService {
  final String baseUrl = "https://api.themoviedb.org/3/search/multi";
  final String movieBaseUrl = "https://api.themoviedb.org/3/search/movie";
  final String tvSeriesBaseUrl = "https://api.themoviedb.org/3/search/tv";
  final String apiKey = dotenv.env["TMDB_API_KEY"]!;

  Future<List<Movie>> fetchSearchMovie({
    required String query,
    bool includeAdult = false,
    int page = 1,
    int? primaryReleaseYear,
  }) async {
    try {
      final uri = Uri.parse(
          "$movieBaseUrl?api_key=$apiKey&query=${Uri.encodeComponent(query)}&include_adult=$includeAdult&page=$page"
          "${primaryReleaseYear != null ? '&primary_release_year=$primaryReleaseYear' : ''}");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
      } else {
        print("Failed to search movies. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error searching movies: $e");
    }

    return [];
  }

  Future<List<TvSerie>> fetchSearchTV({
    required String query,
    bool includeAdult = false,
    int page = 1,
    int? firstAirDateYear,
    String language = "en-US",
  }) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final uri = Uri.parse(
        "$tvSeriesBaseUrl?api_key=$apiKey&query=$encodedQuery&include_adult=$includeAdult&page=$page"
        "${firstAirDateYear != null ? "&first_air_date_year=$firstAirDateYear" : ""}"
        "&language=$language",
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List)
            .map((tvJson) => TvSerie.fromJson(tvJson))
            .toList();
      }
    } catch (e) {
      print("Error searching TV shows: $e");
    }
    return [];
  }

  Future<List<dynamic>> fetchMultiSearch({
    required String query,
    bool includeAdult = false,
    int page = 1,
    String language = "en-US",
  }) async {
    try {
      final uri = Uri.parse(
          "$baseUrl?api_key=$apiKey&query=${Uri.encodeComponent(query)}&include_adult=$includeAdult&page=$page&language=$language");

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> results = data['results'];

        // Optionally map them to proper models if you want typed objects
        return results.map((item) {
          switch (item['media_type']) {
            case 'movie':
              return Movie.fromJson(item);
            case 'tv':
              return TvSerie.fromJson(item);
            case 'person':
              return Person.fromJson(item);
            default:
              return item; // fallback if unknown type
          }
        }).toList();
      } else {
        print("Failed to search. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error searching multi: $e");
      return [];
    }
  }

  /// Fetch trending data (movies, TV shows, people)
  Future<List<dynamic>> fetchTrending({
    String timeWindow = "day", // "day" or "week"
    String language = "en-US",
  }) async {
    try {
      final uri = Uri.parse(
          " https://api.themoviedb.org/3/trending/all/$timeWindow?api_key=$apiKey&language=$language");

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> results = data['results'];

        // Map results based on media_type
        return results.map((item) {
          switch (item['media_type']) {
            case 'movie':
              return Movie.fromJson(item);
            case 'tv':
              return TvSerie.fromJson(item);
            case 'person':
              return Person.fromJson(item);
            default:
              return item; // fallback
          }
        }).toList();
      } else {
        print("Failed to fetch trending. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching trending: $e");
      return [];
    }
  }

  Future<List<Movie>> fetchTrendingMovies({
    String timeWindow = "day", // "day" or "week"
    String language = "en-US",
  }) async {
    try {
      final uri = Uri.parse(
          "https://api.themoviedb.org/3/trending/movie/$timeWindow?api_key=$apiKey&language=$language");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Movie> movies = (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
        return movies;
      } else {
        print(
            "Failed to fetch trending movies. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching trending movies: $e");
      return [];
    }
  }
}
