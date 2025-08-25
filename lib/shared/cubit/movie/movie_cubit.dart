import 'package:cinemind/shared/cubit/movie/movie_state.dart';
import 'package:cinemind/shared/repo/movie_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/movie.dart';

class MovieCubit extends Cubit<MovieState> {
  final MovieRepository repo;

  MovieCubit(this.repo) : super(const MovieInitial());

  Future<void> fetchAllMovies() async {
    // Don't fetch if we already have data
    if (state is MovieLoaded) return;

    // Don't emit loading if we're already loading
    if (state is! MovieLoading) {
      emit(const MovieLoading());
    }

    try {
      final popular = await repo.getPopularMovies();
      final topRated = await repo.getTopRatedMovies();
      final upcoming = await repo.getUpcomingMovies();

      emit(MovieLoaded(
        popular: popular,
        topRated: topRated,
        upcoming: upcoming,
      ));
    } catch (e) {
      emit(MovieError("Failed to load movies: $e"));
    }
  }

  Future<void> fetchCategory(String category) async {
    emit(const MovieLoading());
    try {
      List<Movie> movies = [];
      final currentState =
          state is MovieLoaded ? state as MovieLoaded : const MovieLoaded();

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
        default:
          await fetchAllMovies();
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
