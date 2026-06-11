import 'package:hive/hive.dart';
import '../../model/movie.dart';
import '../service/movie_service.dart';

class MovieRepository {
  // Singleton
  static final MovieRepository _instance = MovieRepository._internal();
  factory MovieRepository() => _instance;
  MovieRepository._internal();

  final MovieService service = MovieService();
  final Box box = Hive.box('movies');

  static const cacheDuration = Duration(hours: 24);

  // In-flight request cache to deduplicate concurrent calls
  final Map<String, Future<dynamic>> _inflight = {};

  // -------------------------------
  // Single movie by ID
  // -------------------------------
  Future<Movie> getMovieById(int id) async {
    final key = 'movie_$id';

    if (box.containsKey(key)) {
      final cached = box.get(key);
      return Movie.fromJson(Map<String, dynamic>.from(cached));
    }

    final movie = await service.fetchMovieById(id);
    if (movie != null) {
      box.put(key, movie.toJson());
      return movie;
    } else {
      throw Exception("Movie with ID $id not found");
    }
  }

  // -------------------------------
  // Generic cache handler
  // -------------------------------
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
        // Refresh in background
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

  // -------------------------------
  // Popular movies
  // -------------------------------
  Future<List<Movie>> getPopularMovies(int page) async {
    return _getCachedMovies(
        'popular_page_$page', () => service.fetchPopularMovie(page: page));
  }

  // -------------------------------
  // Top Rated movies
  // -------------------------------
  Future<List<Movie>> getTopRatedMovies() async {
    return _getCachedMovies('topRated', () => service.fetchTopRatedMovie());
  }

  // -------------------------------
  // Upcoming movies
  // -------------------------------
  Future<List<Movie>> getUpcomingMovies() async {
    return _getCachedMovies('upcoming', () => service.fetchUpcomingMovie());
  }

  // -------------------------------
  // Trending movies
  // -------------------------------
  Future<List<Movie>> getTrendingMovies(String timeWindow, int page) async {
    final key = 'trending_$timeWindow';
    return _getCachedMovies(
      key,
      () => service.fetchTrendingMovie(page: page, timeWindow),
    );
  }

  // -------------------------------
  // Movie images with caching & dedup
  // -------------------------------
  Future<List<String>> getMovieImages(int movieId) async {
    final key = 'images_$movieId';

    if (_inflight.containsKey(key)) {
      return await _inflight[key] as List<String>;
    }

    final cachedData = box.get(key) as Map?;
    if (cachedData != null) {
      final lastFetch =
          DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']);
      final isExpired = DateTime.now().difference(lastFetch) > cacheDuration;

      final images = (cachedData['images'] as List).cast<String>();

      if (isExpired && !_inflight.containsKey(key)) {
        _inflight[key] = service.fetchMovieImages(movieId).then((freshImages) {
          box.put(key, {
            'images': freshImages,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
          _inflight.remove(key);
          return freshImages;
        });
      }

      // Deduplicate and trim
      final dedup = <String>[];
      final seen = <String>{};
      for (var u in images) {
        if (u.isEmpty) continue;
        if (seen.add(u)) dedup.add(u);
        if (dedup.length >= 6) break;
      }
      return dedup;
    }

    // No cache, fetch
    final fetchFuture = service.fetchMovieImages(movieId).then((images) {
      final dedup = <String>[];
      final seen = <String>{};
      for (var s in images) {
        if (s.isEmpty) continue;
        if (seen.add(s)) dedup.add(s);
        if (dedup.length >= 6) break;
      }

      box.put(key, {
        'images': dedup,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      _inflight.remove(key);
      return dedup;
    });

    _inflight[key] = fetchFuture;
    return await fetchFuture;
  }
}
