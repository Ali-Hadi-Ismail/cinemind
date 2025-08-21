import 'package:flutter_dotenv/flutter_dotenv.dart';

class Movieservice {
  final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  final String baseUrl = "https://api.themoviedb.org/3/";
}
