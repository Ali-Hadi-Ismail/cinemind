import 'package:bloc/bloc.dart';
import 'package:cinemind/shared/cubit/tv/tv_detail/tv_detail_state.dart';
import 'package:cinemind/shared/repo/tv_repo.dart';
import 'package:cinemind/model/tv_series.dart';
import 'package:cinemind/model/season.dart';
import 'package:cinemind/model/episode.dart';

class TvDetailCubit extends Cubit<TvDetailState> {
  final TvRepo repo;

  TvDetailCubit({required this.repo}) : super(TvDetailInitial());

  TvSerie? _tvSeries;
  final List<Season> _seasons = [];
  final Map<int, List<Episode>> _episodes = {}; // key = seasonNumber

  // ------------------ Fetch TV Series ------------------
  Future<void> fetchTvSerie(int id) async {
    emit(TvDetailLoading(
        tvSerie: _tvSeries, seasons: _seasons, episodes: _episodes));
    try {
      final tvSerie = await repo.getTvSeries(id);
      if (tvSerie != null) {
        _tvSeries = tvSerie;
        emit(TvDetailLoaded(
            tvSerie: _tvSeries!, seasons: _seasons, episodes: _episodes));
      } else {
        emit(TvDetailError(message: "Tv Series not found."));
      }
    } catch (e) {
      emit(TvDetailError(message: e.toString()));
    }
  }

  // ------------------ Fetch a Season ------------------
  Future<void> fetchTvSeason(int seriesId, int seasonNumber) async {
    emit(TvDetailLoading(
        tvSerie: _tvSeries, seasons: _seasons, episodes: _episodes));
    try {
      final season = await repo.getSeason(seriesId, seasonNumber);
      if (season != null) {
        // Add season only if not already loaded
        if (!_seasons.any((s) => s.seasonNumber == season.seasonNumber)) {
          _seasons.add(season);
        }
        emit(TvDetailLoaded(
            tvSerie: _tvSeries!, seasons: _seasons, episodes: _episodes));
      } else {
        emit(TvDetailError(message: "Season $seasonNumber not found."));
      }
    } catch (e) {
      emit(TvDetailError(message: e.toString()));
    }
  }

  // ------------------ Fetch Episodes for a Season ------------------
  Future<void> fetchEpisodes(int seriesId, int seasonNumber) async {
    emit(TvDetailLoading(
        tvSerie: _tvSeries, seasons: _seasons, episodes: _episodes));
    try {
      final seasonEpisodes = <Episode>[];
      final season = _seasons.firstWhere((s) => s.seasonNumber == seasonNumber,
          orElse: () => Season(
              seasonNumber: seasonNumber,
              episodes: [],
              id: 0,
              name: "",
              airDate: "",
              overview: "",
              voteAverage: 0));

      for (final ep in season.episodes) {
        final episode =
            await repo.getEpisode(seriesId, seasonNumber, ep.episodeNumber);
        if (episode != null) {
          seasonEpisodes.add(episode);
        }
      }

      _episodes[seasonNumber] = seasonEpisodes;
      emit(TvDetailLoaded(
          tvSerie: _tvSeries!, seasons: _seasons, episodes: _episodes));
    } catch (e) {
      emit(TvDetailError(message: e.toString()));
    }
  }
}
