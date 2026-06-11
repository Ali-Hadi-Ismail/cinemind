import 'package:cinemind/shared/repo/search_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model/tv_series.dart';
import 'search_tv_serie_state.dart';

class SearchTvCubit extends Cubit<SearchTvState> {
  final SearchRepo repo;
  int _currentPage = 1;
  List<TvSerie> tvSearchResult = [];
  String _currentQuery = "";
  bool _hasReachedMax = false;

  SearchTvCubit(this.repo) : super(SearchTvInitial());

  int get currentPage => _currentPage;
  bool get hasReachedMax => _hasReachedMax;

  /// Search for TV shows
  Future<void> search(
    String query, {
    int page = 1,
    bool includeAdult = false,
    int? firstAirDateYear,
  }) async {
    if (query.isEmpty) {
      _resetState();
      emit(SearchTvInitial());
      return;
    }

    // If it's a new query, reset everything
    if (query != _currentQuery) {
      _resetState();
      _currentQuery = query;
      page = 1;
    }

    // Don't search if we've reached the maximum or already loading
    if (_hasReachedMax && page > _currentPage) return;

    // Show loading only for the first page
    if (page == 1) emit(SearchTvLoading());

    try {
      final results = await repo.searchTv(
        query,
        page: page,
        includeAdult: includeAdult,
        firstAirDateYear: firstAirDateYear,
      );

      if (results.isEmpty) {
        if (page == 1) {
          emit(SearchTvEmpty());
        } else {
          _hasReachedMax = true;
          emit(SearchTvLoaded(tvSearchResult));
        }
      } else {
        if (page == 1) {
          tvSearchResult = results;
        } else {
          tvSearchResult.addAll(results);
        }

        _currentPage = page;

        // If we got fewer than 20 results, we may be at the end
        if (results.length < 20) _hasReachedMax = true;

        emit(SearchTvLoaded(tvSearchResult));
      }
    } catch (e) {
      emit(SearchTvError(e.toString()));
    }
  }

  /// Load the next page of results
  Future<void> loadNextPage({
    bool includeAdult = false,
    int? firstAirDateYear,
  }) async {
    if (_hasReachedMax || _currentQuery.isEmpty) return;
    await search(
      _currentQuery,
      page: _currentPage + 1,
      includeAdult: includeAdult,
      firstAirDateYear: firstAirDateYear,
    );
  }

  void _resetState() {
    _currentPage = 1;
    tvSearchResult = [];
    _currentQuery = "";
    _hasReachedMax = false;
  }
}
