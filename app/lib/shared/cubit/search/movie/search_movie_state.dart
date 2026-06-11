import 'package:cinemind/model/movie.dart';

abstract class SearchMovieState {}

class SearchMovieInitial extends SearchMovieState {}

class SearchMovieLoading extends SearchMovieState {}

class SearchMovieLoaded extends SearchMovieState {
  final List<Movie> results;
  SearchMovieLoaded(this.results);
}

class SearchMovieError extends SearchMovieState {
  final String message;
  SearchMovieError(this.message);
}

class SearchMovieEmpty extends SearchMovieState {}
