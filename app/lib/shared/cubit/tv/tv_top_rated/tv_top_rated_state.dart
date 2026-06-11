import 'package:equatable/equatable.dart';
import '../../../../model/tv_series.dart';

abstract class TvTopRatedState extends Equatable {
  const TvTopRatedState();

  @override
  List<Object?> get props => [];
}

class TvTopRatedInitial extends TvTopRatedState {
  const TvTopRatedInitial();
}

class TvTopRatedLoading extends TvTopRatedState {
  const TvTopRatedLoading();
}

class TvTopRatedLoaded extends TvTopRatedState {
  final List<TvSerie> topRatedList;

  const TvTopRatedLoaded({required this.topRatedList});

  @override
  List<Object?> get props => [topRatedList];
}

class TvTopRatedError extends TvTopRatedState {
  final String message;

  const TvTopRatedError({required this.message});

  @override
  List<Object?> get props => [message];
}
