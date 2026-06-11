import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repo/tv_repo.dart';
import 'tv_popular_state.dart';

class TvPopularCubit extends Cubit<TvPopularState> {
  final TvRepo repo;

  TvPopularCubit({required this.repo}) : super(const TvPopularInitial());

  Future<void> fetchPopularList() async {
    // Prevent refetch if already loaded
    if (state is TvPopularLoaded) {
      return;
    }

    try {
      // Only emit loading if not already loading
      if (state is! TvPopularLoading) {
        emit(const TvPopularLoading());
      }

      final popularList = await repo.getPopular();

      if (popularList != null && popularList.isNotEmpty) {
        emit(TvPopularLoaded(popularList: popularList));
      } else {
        emit(const TvPopularError(message: "No popular TV series found."));
      }
    } catch (e) {
      print('💥 Popular Cubit: Exception caught: $e');
      print('💥 Popular Cubit: Stack trace: ${StackTrace.current}');
      emit(TvPopularError(message: "Failed to fetch popular list: $e"));
    }
  }
}
