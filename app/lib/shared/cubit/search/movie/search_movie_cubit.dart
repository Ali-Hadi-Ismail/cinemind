import 'package:cinemind/shared/cubit/search/movie/search_movie_state.dart';
import 'package:cinemind/shared/repo/search_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model/movie.dart';

class SearchMovieCubit extends Cubit<SearchMovieState> {
  final SearchRepo repo;
  int _currentPage = 1;
  List<Movie> movieSearchResult = [];
  String _currentQuery = "";
  bool _hasReachedMax = false;

  SearchMovieCubit(this.repo) : super(SearchMovieInitial());

  int get currentPage => _currentPage;
  bool get hasReachedMax => _hasReachedMax;

  /// Search for [query]. If it's a new query, reset everything.
  /// If it's the same query with a higher page, append results.
  Future<void> search(
    String query, {
    int page = 1,
    int? year,
    String? region,
    bool includeAdult = false,
  }) async {
    if (query.isEmpty) {
      _resetState();
      emit(SearchMovieInitial());
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
    if (page == 1) {
      emit(SearchMovieLoading());
    }

    try {
      final results = await repo.searchMovies(
        query,
        page: page,
        includeAdult: includeAdult,
        year: year,
      );

      if (results.isEmpty) {
        if (page == 1) {
          emit(SearchMovieEmpty());
        } else {
          // No more results to load
          _hasReachedMax = true;
          emit(SearchMovieLoaded(movieSearchResult));
        }
      } else {
        if (page == 1) {
          movieSearchResult = results;
        } else {
          movieSearchResult.addAll(results);
        }

        _currentPage = page;

        // If we got fewer results than expected (usually 20 per page),
        // we might have reached the end
        if (results.length < 20) {
          _hasReachedMax = true;
        }

        emit(SearchMovieLoaded(movieSearchResult));
      }
    } catch (e) {
      emit(SearchMovieError(e.toString()));
    }
  }

  /// Load the next page of results for the current query
  Future<void> loadNextPage({
    int? year,
    String? language,
    String? region,
    bool includeAdult = false,
  }) async {
    if (_hasReachedMax || _currentQuery.isEmpty) return;
    await search(
      _currentQuery,
      page: _currentPage + 1,
      year: year,
      region: region,
      includeAdult: includeAdult,
    );
  }

  void _resetState() {
    _currentPage = 1;
    movieSearchResult = [];
    _currentQuery = "";
    _hasReachedMax = false;
  }
}
