import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repo/tv_repo.dart';
import 'tv_trending_state.dart';

class TvTrendingCubit extends Cubit<TvTrendingState> {
  final TvRepo repo;
  int _currentPage = 1;
  bool _hasReachedMax = false;

  TvTrendingCubit({required this.repo}) : super(const TvTrendingInitial());

  /// Fetch initial trending list (page 1)
  Future<void> fetchTrendingList() async {
    // Don't fetch if we already have data and we're not refreshing
    if (state is TvTrendingLoaded && !_shouldRefresh()) {
      return;
    }

    try {
      // Don't emit loading if we're already loading
      if (state is! TvTrendingLoading) {
        emit(const TvTrendingLoading());
      }

      print('🎬 Cubit: Fetching trending list page $_currentPage');
      final trendingList = await repo.getTrendingTvSeries(page: 1);

      if (trendingList != null && trendingList.isNotEmpty) {
        _currentPage = 1;
        _hasReachedMax = trendingList.length < 20; // Assuming 20 items per page

        final newState = TvTrendingLoaded(
          trendingList: trendingList,
          hasReachedMax: _hasReachedMax,
          currentPage: _currentPage,
        );
        emit(newState);
        print(
            '🎬 Cubit: Loaded ${trendingList.length} trending shows for page $_currentPage');
      } else {
        emit(const TvTrendingError(message: "No trending TV series found."));
      }
    } catch (e) {
      print('💥 Cubit: Exception caught: $e');
      print('💥 Cubit: Stack trace: ${StackTrace.current}');
      emit(TvTrendingError(message: "Failed to fetch trending list: $e"));
    }
  }

  /// Load more trending shows (pagination)
  Future<void> loadMoreTrending() async {
    if (_hasReachedMax || state is! TvTrendingLoaded) {
      return;
    }

    final currentState = state as TvTrendingLoaded;
    if (currentState.isLoadingMore) {
      return; // Already loading more
    }

    try {
      // Emit state with loading more flag
      emit(currentState.copyWith(isLoadingMore: true));

      final nextPage = _currentPage + 1;
      print('🎬 Cubit: Loading more trending shows - page $nextPage');

      final newItems = await repo.getTrendingTvSeries(page: nextPage);

      if (newItems != null && newItems.isNotEmpty) {
        _currentPage = nextPage;
        _hasReachedMax = newItems.length < 20; // Assuming 20 items per page

        final updatedList = [...currentState.trendingList, ...newItems];

        emit(TvTrendingLoaded(
          trendingList: updatedList,
          hasReachedMax: _hasReachedMax,
          currentPage: _currentPage,
          isLoadingMore: false,
        ));

        print(
            '🎬 Cubit: Loaded ${newItems.length} more shows. Total: ${updatedList.length}');
      } else {
        _hasReachedMax = true;
        emit(currentState.copyWith(
          hasReachedMax: true,
          isLoadingMore: false,
        ));
        print('🎬 Cubit: No more trending shows available');
      }
    } catch (e) {
      print('💥 Cubit: Exception loading more: $e');
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Refresh the trending list (reset to page 1)
  Future<void> refreshTrendingList() async {
    try {
      emit(const TvTrendingLoading());
      _currentPage = 1;
      _hasReachedMax = false;

      print('🎬 Cubit: Refreshing trending list');
      final trendingList = await repo.getTrendingTvSeries(page: 1);

      if (trendingList != null && trendingList.isNotEmpty) {
        _hasReachedMax = trendingList.length < 20;

        emit(TvTrendingLoaded(
          trendingList: trendingList,
          hasReachedMax: _hasReachedMax,
          currentPage: _currentPage,
        ));
        print('🎬 Cubit: Refreshed with ${trendingList.length} trending shows');
      } else {
        emit(const TvTrendingError(message: "No trending TV series found."));
      }
    } catch (e) {
      print('💥 Cubit: Exception refreshing: $e');
      emit(TvTrendingError(message: "Failed to refresh trending list: $e"));
    }
  }

  /// Check if we should refresh the data (e.g., if it's been a while)
  bool _shouldRefresh() {
    // You can implement time-based refresh logic here
    // For now, we'll assume no automatic refresh is needed
    return false;
  }

  /// Get current page number
  int get currentPage => _currentPage;

  /// Check if more data can be loaded
  bool get canLoadMore => !_hasReachedMax && state is TvTrendingLoaded;

  /// Reset cubit state
  void reset() {
    _currentPage = 1;
    _hasReachedMax = false;
    emit(const TvTrendingInitial());
  }
}
