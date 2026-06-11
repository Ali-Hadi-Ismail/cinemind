import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repo/movie_repo.dart';
import 'movie_popular_state.dart';

class MoviePopularCubit extends Cubit<MoviePopularState> {
  final MovieRepository repo;
  int _currentPage = 1;
  bool _hasReachedMax = false;

  MoviePopularCubit({required this.repo}) : super(const MoviePopularInitial());

  /// Fetch initial popular movies (page 1)
  Future<void> fetchPopularMovies() async {
    if (state is MoviePopularLoaded && !_shouldRefresh()) {
      return;
    }

    try {
      if (state is! MoviePopularLoading) {
        emit(const MoviePopularLoading());
      }

      print('🎬 Cubit: Fetching popular movies page $_currentPage');
      final popularList = await repo.getPopularMovies(1);

      if (popularList.isNotEmpty) {
        _currentPage = 1;
        _hasReachedMax = popularList.length < 20;

        emit(MoviePopularLoaded(
          popularList: popularList,
          hasReachedMax: _hasReachedMax,
          currentPage: _currentPage,
        ));

        print(
            '🎬 Cubit: Loaded ${popularList.length} popular movies for page $_currentPage');
      } else {
        emit(const MoviePopularError(message: "No popular movies found."));
      }
    } catch (e) {
      print('💥 Cubit: Exception caught: $e');
      emit(MoviePopularError(message: "Failed to fetch popular movies: $e"));
    }
  }

  /// Load more popular movies (pagination)
  Future<void> loadMorePopularMovies() async {
    if (_hasReachedMax || state is! MoviePopularLoaded) return;

    final currentState = state as MoviePopularLoaded;
    if (currentState.isLoadingMore) return;

    try {
      emit(currentState.copyWith(isLoadingMore: true));

      final nextPage = _currentPage + 1;
      print('🎬 Cubit: Loading more popular movies - page $nextPage');

      final newItems = await repo.getPopularMovies(nextPage);

      if (newItems.isNotEmpty) {
        _currentPage = nextPage;
        _hasReachedMax = newItems.length < 20;

        final updatedList = [...currentState.popularList, ...newItems];

        emit(MoviePopularLoaded(
          popularList: updatedList,
          hasReachedMax: _hasReachedMax,
          currentPage: _currentPage,
          isLoadingMore: false,
        ));

        print(
            '🎬 Cubit: Loaded ${newItems.length} more movies. Total: ${updatedList.length}');
      } else {
        _hasReachedMax = true;
        emit(currentState.copyWith(
          hasReachedMax: true,
          isLoadingMore: false,
        ));
        print('🎬 Cubit: No more popular movies available');
      }
    } catch (e) {
      print('💥 Cubit: Exception loading more: $e');
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Refresh the popular movies list
  Future<void> refreshPopularMovies() async {
    try {
      emit(const MoviePopularLoading());
      _currentPage = 1;
      _hasReachedMax = false;

      print('🎬 Cubit: Refreshing popular movies list');
      final popularList = await repo.getPopularMovies(1);

      if (popularList.isNotEmpty) {
        _hasReachedMax = popularList.length < 20;

        emit(MoviePopularLoaded(
          popularList: popularList,
          hasReachedMax: _hasReachedMax,
          currentPage: _currentPage,
        ));
        print('🎬 Cubit: Refreshed with ${popularList.length} popular movies');
      } else {
        emit(const MoviePopularError(message: "No popular movies found."));
      }
    } catch (e) {
      print('💥 Cubit: Exception refreshing: $e');
      emit(MoviePopularError(message: "Failed to refresh popular movies: $e"));
    }
  }

  /// Optional auto-refresh logic
  bool _shouldRefresh() {
    return false;
  }

  int get currentPage => _currentPage;

  bool get canLoadMore => !_hasReachedMax && state is MoviePopularLoaded;

  void reset() {
    _currentPage = 1;
    _hasReachedMax = false;
    emit(const MoviePopularInitial());
  }
}
