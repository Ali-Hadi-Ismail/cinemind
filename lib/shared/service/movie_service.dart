import 'dart:convert';
import 'package:cinemind/model/cast.dart';
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
        // Decode once
        final decoded = jsonDecode(response.body);

        // 🔎 Debug logs
        print("➡️ fetchMovieById($id)");
        print("decoded runtimeType: ${decoded.runtimeType}");
        if (decoded is Map) {
          print(
              "decoded keys types: ${decoded.keys.map((k) => k.runtimeType).toSet()}");
        }

        // ✅ Safe conversion to Map<String, dynamic>
        final safeMap = Map<String, dynamic>.from(decoded);
        return Movie.fromJson(safeMap);
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

  Future<String?> getMovieTrailer(int movieId) async {
    final url = Uri.parse(
      'https://api.themoviedb.org/3/movie/$movieId/videos?language=en-US&api_key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;

      // Look for a YouTube trailer
      final trailer = results.firstWhere(
        (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
        orElse: () => null,
      );

      if (trailer != null) {
        return trailer['key']; // This is the YouTube video key
      }
    }
    return null; // No trailer found
  }

  Future<List<String>> fetchMovieImages(int movieId) async {
    final uri = Uri.parse(
        "https://api.themoviedb.org/3/movie/$movieId/images?api_key=$apiKey");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> posters = (data['posters'] as List)
          .map((item) => "https://image.tmdb.org/t/p/w500${item['file_path']}")
          .toList();
      List<String> backdrops = (data['backdrops'] as List)
          .map((item) => "https://image.tmdb.org/t/p/w780${item['file_path']}")
          .toList();
      return [...posters, ...backdrops];
    } else {
      return [];
    }
  }

  Future<List<Cast>> getCastByMovieById(int movieId) async {
    final uri = Uri.https("api.themoviedb.org", "/3/movie/$movieId/credits",
        {"language": "en-US", "api_key": apiKey});
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final castJson = data['cast'] as List? ?? [];
        return castJson.map((e) => Cast.fromJson(e)).toList();
      } else {
        throw Exception("Failed with status ${response.statusCode}");
      }
    } catch (e, stack) {
      print("💥 Hey king, check this error: $e");
      print("💥 Stack trace: $stack");
      return [];
    }
  }

  Future<Cast?> getPersonDetailById(int personId) async {
    final uri = Uri.https(
      "api.themoviedb.org",
      "/3/person/$personId",
      {"language": "en-US", "api_key": apiKey},
    );

    print("🔹 Requesting person details from TMDb for ID: $personId");
    print("🔹 URI: $uri");

    try {
      final response = await http.get(uri);

      print("🔹 Response status: ${response.statusCode}");
      print("🔹 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("🔹 JSON decoded successfully");

        // Optionally, print all keys returned
        print("🔹 Keys in JSON: ${data.keys.toList()}");

        final cast = Cast.fromJson(data);
        print("🔹 Cast object created: ${cast.name}, ID: ${cast.id}");
        return cast;
      } else {
        print("💥 Failed to get person: ${response.statusCode}");
        return null;
      }
    } catch (e, stack) {
      print("💥 Exception caught while fetching person details: $e");
      print("💥 Stack trace: $stack");
      return null;
    }
  }
}
