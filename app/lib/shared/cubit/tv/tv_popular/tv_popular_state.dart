import 'package:equatable/equatable.dart';
import '../../../../model/tv_series.dart';

abstract class TvPopularState extends Equatable {
  const TvPopularState();

  @override
  List<Object?> get props => [];
}

class TvPopularInitial extends TvPopularState {
  const TvPopularInitial();
}

class TvPopularLoading extends TvPopularState {
  const TvPopularLoading();
}

class TvPopularLoaded extends TvPopularState {
  final List<TvSerie> popularList;

  const TvPopularLoaded({required this.popularList});

  @override
  List<Object?> get props => [popularList];
}

class TvPopularError extends TvPopularState {
  final String message;

  const TvPopularError({required this.message});

  @override
  List<Object?> get props => [message];
}
