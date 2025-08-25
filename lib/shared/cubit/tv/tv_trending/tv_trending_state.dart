import 'package:equatable/equatable.dart';
import '../../../../model/tv_series.dart';

abstract class TvTrendingState extends Equatable {
  const TvTrendingState();

  @override
  List<Object?> get props => [];
}

class TvTrendingInitial extends TvTrendingState {
  const TvTrendingInitial();
}

class TvTrendingLoading extends TvTrendingState {
  const TvTrendingLoading();
}

class TvTrendingLoaded extends TvTrendingState {
  final List<TvSerie> trendingList;

  const TvTrendingLoaded({required this.trendingList});

  @override
  List<Object?> get props => [trendingList];
}

class TvTrendingError extends TvTrendingState {
  final String message;

  const TvTrendingError({required this.message});

  @override
  List<Object?> get props => [message];
}
