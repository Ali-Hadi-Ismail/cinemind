import 'package:cinemind/shared/cubit/movie/movie_state.dart';
import 'package:cinemind/shared/repo/movie_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/movie.dart';

class MovieCubit extends Cubit<MovieState> {
  final MovieRepository repo;

  MovieCubit(this.repo) : super(MovieInitial()) {
    fetchAllMovies(); // fetch all categories at once
  }

  Future<void> fetchAllMovies() async {
    emit(MovieLoading());
    try {
      // Fetch all categories in parallel
      final popularFuture = repo.getPopularMovies();
      final topRatedFuture = repo.getTopRatedMovies();
      final upcomingFuture = repo.getUpcomingMovies();

      final results =
          await Future.wait([popularFuture, topRatedFuture, upcomingFuture]);

      final popular = results[0];
      final topRated = results[1];
      final upcoming = results[2];

      emit(MovieLoaded(
        popular: popular,
        topRated: topRated,
        upcoming: upcoming,
      ));
    } catch (e) {
      emit(MovieError("Failed to load movies: $e"));
    }
  }

  /// Optional: Fetch only one category later if needed
  Future<void> fetchCategory(String category) async {
    if (state is! MovieLoaded) return; // ensure we have base state

    final currentState = state as MovieLoaded;
    List<Movie> movies = [];

    try {
      switch (category) {
        case "popular":
          movies = await repo.getPopularMovies();
          emit(currentState.copyWith(popular: movies));
          break;
        case "top_rated":
          movies = await repo.getTopRatedMovies();
          emit(currentState.copyWith(topRated: movies));
          break;
        case "upcoming":
          movies = await repo.getUpcomingMovies();
          emit(currentState.copyWith(upcoming: movies));
          break;
      }
    } catch (e) {
      emit(MovieError("Failed to load $category: $e"));
    }
  }
}

extension on MovieLoaded {
  MovieLoaded copyWith({
    List<Movie>? popular,
    List<Movie>? topRated,
    List<Movie>? upcoming,
  }) {
    return MovieLoaded(
      popular: popular ?? this.popular,
      topRated: topRated ?? this.topRated,
      upcoming: upcoming ?? this.upcoming,
    );
  }
}
