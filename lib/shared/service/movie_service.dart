import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../model/movie.dart';
import 'package:http/http.dart' as http;

class MovieService {
  final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  final String baseUrl = "https://api.themoviedb.org/3/movie";

  Future<Movie?> fetchMovieById(int id) async {
    try {
      final uri = Uri.parse("$baseUrl/$id?api_key=$apiKey");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return Movie.fromJson(jsonDecode(response.body));
      } else {
        print("Failed to fetch movie. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching movie: $e");
      return null;
    }
  }

  Future<List<Movie>> fetchMovieSimilarRecommendation(int id) async {
    try {
      final uri = Uri.parse("$baseUrl/$id/recommendations?api_key=$apiKey");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Movie> list = (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
        return list;
      } else {
        print("Failed to fetch movie. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching movie: $e");
      return [];
    }
  }

  Future<List<Movie>> fetchPopularMovie({int page = 1}) async {
    try {
      final uri = Uri.parse("$baseUrl/popular?api_key=$apiKey&page=$page");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Movie>> fetchUpcomingMovie({int page = 1}) async {
    try {
      final uri = Uri.parse("$baseUrl/upcoming?api_key=$apiKey&page=$page");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Movie>> fetchTopRatedMovie({int page = 1}) async {
    try {
      final uri = Uri.parse("$baseUrl/top_rated?api_key=$apiKey&page=$page");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
