import 'package:bloc/bloc.dart';

import '../../../../model/movie.dart';
import '../../../repo/movie_repo.dart';
import 'movie_trending_state.dart';

class MovieTrendingCubit extends Cubit<MovieTrendingState> {
  final MovieRepository repo;
  int _page = 1;

  MovieTrendingCubit({required this.repo}) : super(MovieTrendingInitial());

  void fetchTrending(String timeWindow) async {
    if (state is MovieTrendingLoaded &&
        (state as MovieTrendingLoaded).hasReachedEnd) {
      return;
    }

    try {
      if (state is! MovieTrendingLoaded) {
        emit(MovieTrendingLoading());
        final movies = await repo.getTrendingMovies(timeWindow, _page);
        _page++;
        emit(
            MovieTrendingLoaded(movies: movies, hasReachedEnd: movies.isEmpty));
      } else {
        final current = state as MovieTrendingLoaded;
        emit(current.copyWith(isLoadingNextPage: true));

        final movies = await repo.getTrendingMovies(timeWindow, _page);
        _page++;

        final allMovies = List<Movie>.from(current.movies)..addAll(movies);
        emit(MovieTrendingLoaded(
          movies: allMovies,
          hasReachedEnd: movies.isEmpty,
        ));
      }
    } catch (e) {
      emit(MovieTrendingError("Failed to load trending movies: $e"));
    }
  }
}
