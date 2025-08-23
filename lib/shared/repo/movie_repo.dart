import 'package:hive/hive.dart';
import '../../model/movie.dart';
import '../service/movie_service.dart';

class MovieRepository {
  final MovieService service = MovieService();
  final Box box = Hive.box('movies');

  static const cacheDuration = Duration(hours: 24);

  /// Generic function to get cached data or fetch fresh
  Future<List<Movie>> _getCachedMovies(
      String key, Future<List<Movie>> Function() fetcher) async {
    final cachedData = box.get(key) as Map?;
    if (cachedData != null) {
      final lastFetch =
          DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']);
      final isExpired = DateTime.now().difference(lastFetch) > cacheDuration;

      final movies = (cachedData['movies'] as List)
          .map((e) => Movie.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (isExpired) {
        // Fetch fresh data in background
        fetcher().then((freshMovies) {
          box.put(key, {
            'movies': freshMovies.map((e) => e.toJson()).toList(),
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        });
      }

      return movies;
    }

    // No cache, fetch and save
    final movies = await fetcher();
    box.put(key, {
      'movies': movies.map((e) => e.toJson()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    return movies;
  }

  // Popular movies
  Future<List<Movie>> getPopularMovies() async {
    return _getCachedMovies('popular', () => service.fetchPopularMovie());
  }

  // Top Rated movies
  Future<List<Movie>> getTopRatedMovies() async {
    return _getCachedMovies('topRated', () => service.fetchTopRatedMovie());
  }

  // Upcoming movies
  Future<List<Movie>> getUpcomingMovies() async {
    return _getCachedMovies('upcoming', () => service.fetchUpcomingMovie());
  }

  // Fetch images for a movie with caching
  Future<List<String>> getMovieImages(int movieId) async {
    final key = 'images_$movieId';
    final cachedData = box.get(key) as Map?;

    if (cachedData != null) {
      final lastFetch =
          DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']);
      final isExpired = DateTime.now().difference(lastFetch) > cacheDuration;

      final images = (cachedData['images'] as List).cast<String>();

      if (isExpired) {
        service.fetchMovieImages(movieId).then((freshImages) {
          box.put(key, {
            'images': freshImages,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        });
      }

      return images;
    }

    // No cache, fetch and save
    final images = await service.fetchMovieImages(movieId);
    box.put(key, {
      'images': images,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    return images;
  }
}
