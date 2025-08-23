import 'package:cinemind/shared/cubit/movie/movie_state.dart';
import 'package:cinemind/shared/service/hive_service.dart';
import 'package:cinemind/shared/service/movie_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MovieCubit extends Cubit<MovieState> {
  final HiveService hiveService;
  final MovieService apiService;
  MovieCubit(this.hiveService, this.apiService)
      : super(
          MovieInitial(),
        );
/*   Future<void> fetchMovies(String key) async {
    emit(MovieLoading());
    if(hiveService.is)
  } */
}
