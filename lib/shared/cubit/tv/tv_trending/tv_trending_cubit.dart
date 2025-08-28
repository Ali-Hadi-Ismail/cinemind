import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repo/tv_repo.dart';
import 'tv_trending_state.dart';

class TvTrendingCubit extends Cubit<TvTrendingState> {
  final TvRepo repo;

  TvTrendingCubit({required this.repo}) : super(const TvTrendingInitial());

  // Replace your fetchTrendingList method with this debug version:

  Future<void> fetchTrendingList() async {
    // Don't fetch if we already have data
    if (state is TvTrendingLoaded) {
      return;
    }

    try {
      // Don't emit loading if we're already loading
      if (state is! TvTrendingLoading) {
        emit(const TvTrendingLoading());
      } else {}

      final trendingList = await repo.getTrendingTvSeries();

      if (trendingList != null && trendingList.isNotEmpty) {
        final newState = TvTrendingLoaded(trendingList: trendingList);
        emit(newState);
        if (state is TvTrendingLoaded) {
          final currentState = state as TvTrendingLoaded;
        }
      } else {
        emit(const TvTrendingError(message: "No trending TV series found."));
      }
    } catch (e) {
      print('💥 Cubit: Exception caught: $e');
      print('💥 Cubit: Stack trace: ${StackTrace.current}');
      emit(TvTrendingError(message: "Failed to fetch trending list: $e"));
    }
  }
}
