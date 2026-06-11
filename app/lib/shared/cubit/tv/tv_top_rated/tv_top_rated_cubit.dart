import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repo/tv_repo.dart';
import 'tv_top_rated_state.dart';

class TvTopRatedCubit extends Cubit<TvTopRatedState> {
  final TvRepo repo;

  TvTopRatedCubit({required this.repo}) : super(const TvTopRatedInitial());

  Future<void> fetchTopRatedList() async {
    // Avoid refetch if already loaded
    if (state is TvTopRatedLoaded) {
      return;
    }

    try {
      if (state is! TvTopRatedLoading) {
        emit(const TvTopRatedLoading());
      }

      final topRatedList = await repo.getTopRated();

      if (topRatedList != null && topRatedList.isNotEmpty) {
        emit(TvTopRatedLoaded(topRatedList: topRatedList));
      } else {
        emit(const TvTopRatedError(message: "No top rated TV series found."));
      }
    } catch (e) {
      print('💥 TopRated Cubit: Exception caught: $e');
      print('💥 TopRated Cubit: Stack trace: ${StackTrace.current}');
      emit(TvTopRatedError(message: "Failed to fetch top rated list: $e"));
    }
  }
}
