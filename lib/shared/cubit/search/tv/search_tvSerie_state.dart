import 'package:cinemind/model/tv_series.dart';

abstract class SearchTvState {}

class SearchTvInitial extends SearchTvState {}

class SearchTvLoading extends SearchTvState {}

class SearchTvLoaded extends SearchTvState {
  final List<TvSerie> results;
  SearchTvLoaded(this.results);
}

class SearchTvError extends SearchTvState {
  final String message;
  SearchTvError(this.message);
}

class SearchTvEmpty extends SearchTvState {}
