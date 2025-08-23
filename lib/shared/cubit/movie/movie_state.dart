import '../../../model/movie.dart';

abstract class MovieState {}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<Movie> popular;
  final List<Movie> topRated;
  final List<Movie> upcoming;

  MovieLoaded({
    this.popular = const [],
    this.topRated = const [],
    this.upcoming = const [],
  });
}

class MovieError extends MovieState {
  final String message;
  MovieError(this.message);
}
