import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repo/tv_repo.dart';
import 'tv_trending_state.dart';

class TvTrendingCubit extends Cubit<TvTrendingState> {
  final TvRepo repo;

  TvTrendingCubit({required this.repo}) : super(const TvTrendingInitial());

  Future<void> fetchTrendingList() async {
    try {
      emit(const TvTrendingLoading());
      final trendingList = await repo.getTrendingTvSeries();

      if (trendingList != null && trendingList.isNotEmpty) {
        emit(TvTrendingLoaded(trendingList: trendingList));
      } else {
        emit(const TvTrendingError(message: "No trending TV series found."));
      }
    } catch (e) {
      emit(TvTrendingError(message: "Failed to fetch trending list: $e"));
    }
  }
}
