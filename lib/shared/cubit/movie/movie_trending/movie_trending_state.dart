import '../../../../model/movie.dart';

abstract class MovieTrendingState {}

class MovieTrendingInitial extends MovieTrendingState {}

class MovieTrendingLoading extends MovieTrendingState {}

class MovieTrendingLoaded extends MovieTrendingState {
  final List<Movie> movies;
  final bool hasReachedEnd;
  final bool isLoadingNextPage;

  MovieTrendingLoaded({
    required this.movies,
    this.hasReachedEnd = false,
    this.isLoadingNextPage = false,
  });

  MovieTrendingLoaded copyWith({
    List<Movie>? movies,
    bool? hasReachedEnd,
    bool? isLoadingNextPage,
  }) {
    return MovieTrendingLoaded(
      movies: movies ?? this.movies,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
    );
  }
}

class MovieTrendingError extends MovieTrendingState {
  final String message;
  MovieTrendingError(this.message);
}
