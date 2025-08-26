import 'package:equatable/equatable.dart';
import '../../../model/movie.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object?> get props => [];
}

class MovieInitial extends MovieState {
  const MovieInitial();
}

class MovieLoading extends MovieState {
  const MovieLoading();
}

class MovieLoaded extends MovieState {
  final List<Movie> popular;
  final List<Movie> topRated;
  final List<Movie> upcoming;
  final Movie? detailedMovie;
  const MovieLoaded({
    this.detailedMovie,
    this.popular = const [],
    this.topRated = const [],
    this.upcoming = const [],
  });

  @override
  // Include detailedMovie so state changes when detail is loaded
  @override
  List<Object?> get props => [popular, topRated, upcoming, detailedMovie];

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

class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);

  @override
  List<Object?> get props => [message];
}
