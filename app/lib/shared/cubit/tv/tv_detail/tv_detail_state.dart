import 'package:equatable/equatable.dart';
import 'package:cinemind/model/tv_series.dart';
import 'package:cinemind/model/season.dart';
import 'package:cinemind/model/episode.dart';

abstract class TvDetailState extends Equatable {
  const TvDetailState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TvDetailInitial extends TvDetailState {
  const TvDetailInitial();
}

// Loading state, can optionally carry previous data to avoid UI flicker
class TvDetailLoading extends TvDetailState {
  final TvSerie? tvSerie;
  final List<Season>? seasons;
  final Map<int, List<Episode>>? episodes;

  const TvDetailLoading({this.tvSerie, this.seasons, this.episodes});

  @override
  List<Object?> get props => [
        tvSerie ?? {},
        seasons ?? [],
        episodes ?? {},
      ];
}

// Loaded state, flexible: can hold series only, series + seasons, or series + seasons + episodes
class TvDetailLoaded extends TvDetailState {
  final TvSerie tvSerie; // Required
  final List<Season> seasons; // Optional, default empty list
  final Map<int, List<Episode>> episodes; // Optional, default empty map

  const TvDetailLoaded({
    required this.tvSerie,
    List<Season>? seasons,
    Map<int, List<Episode>>? episodes,
  })  : seasons = seasons ?? const [],
        episodes = episodes ?? const {};

  @override
  List<Object?> get props => [tvSerie, seasons, episodes];

  // copyWith for partial updates without overwriting existing data
  TvDetailLoaded copyWith({
    TvSerie? tvSerie,
    List<Season>? seasons,
    Map<int, List<Episode>>? episodes,
  }) {
    return TvDetailLoaded(
      tvSerie: tvSerie ?? this.tvSerie,
      seasons: seasons ?? this.seasons,
      episodes: episodes ?? this.episodes,
    );
  }
}

// Error state
class TvDetailError extends TvDetailState {
  final String message;
  const TvDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
