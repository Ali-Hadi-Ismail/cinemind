import 'package:equatable/equatable.dart';
import 'package:cinemind/model/tv_series.dart';

/// ---- STATES ---- ///
abstract class TvPopularState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TvPopularInitial extends TvPopularState {}

class TvPopularLoading extends TvPopularState {}

class TvPopularLoaded extends TvPopularState {
  final List<TvSerie> popularList;

  TvPopularLoaded({required this.popularList});

  @override
  List<Object?> get props => [popularList];
}

class TvPopularError extends TvPopularState {
  final String message;

  TvPopularError({required this.message});

  @override
  List<Object?> get props => [message];
}
