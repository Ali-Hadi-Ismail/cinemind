import 'package:cinemind/shared/cubit/search/search_state.dart';
import 'package:cinemind/shared/repo/search_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo repo;
  int _currentPage = 1;

  SearchCubit(this.repo) : super(SearchInitial());

  int get currentPage => _currentPage;

  /// Search for [query]. Results always replace the current list. The
  /// cubit keeps track of the current page in [_currentPage].
  Future<void> search(String query, {int page = 1}) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    emit(SearchLoading());

    try {
      final results =
          await repo.searchMovies(query, page: page, includeAdult: true);

      if (results.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchLoaded(results));
      }

      _currentPage = page;
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
