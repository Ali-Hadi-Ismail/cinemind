import 'package:bloc/bloc.dart';

import '../../../repo/tv_repo.dart';
import 'tv_popular_state.dart';

class TvPopularCubit extends Cubit<TvPopularState> {
  final TvRepo repo;

  TvPopularCubit({required this.repo}) : super(const TvPopularInitial());

  Future<void> fetchPopularList() async {
    try {
      emit(const TvPopularLoading());
      final popularList = await repo.getPopular();

      if (popularList != null && popularList.isNotEmpty) {
        emit(TvPopularLoaded(popularList: popularList));
      } else {
        emit(TvPopularError(message: "No popular TV series found."));
      }
    } catch (e) {
      emit(TvPopularError(message: "Failed to fetch popular list: $e"));
    }
  }
}
