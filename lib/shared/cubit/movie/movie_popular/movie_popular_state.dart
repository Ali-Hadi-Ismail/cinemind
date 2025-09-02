import 'package:equatable/equatable.dart';
import '../../../../model/movie.dart';

abstract class MoviePopularState extends Equatable {
  const MoviePopularState();

  @override
  List<Object?> get props => [];
}

class MoviePopularInitial extends MoviePopularState {
  const MoviePopularInitial();
}

class MoviePopularLoading extends MoviePopularState {
  const MoviePopularLoading();
}

class MoviePopularLoaded extends MoviePopularState {
  final List<Movie> popularList;
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;

  const MoviePopularLoaded({
    required this.popularList,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props =>
      [popularList, hasReachedMax, currentPage, isLoadingMore];

  MoviePopularLoaded copyWith({
    List<Movie>? popularList,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return MoviePopularLoaded(
      popularList: popularList ?? this.popularList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  bool get canLoadMore => !hasReachedMax && !isLoadingMore;

  int get totalItems => popularList.length;

  @override
  String toString() {
    return 'MoviePopularLoaded{items: ${popularList.length}, page: $currentPage, hasReachedMax: $hasReachedMax, isLoadingMore: $isLoadingMore}';
  }
}

class MoviePopularError extends MoviePopularState {
  final String message;

  const MoviePopularError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'MoviePopularError{message: $message}';
}
