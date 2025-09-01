import 'package:equatable/equatable.dart';
import '../../../../model/tv_series.dart';

abstract class TvTrendingState extends Equatable {
  const TvTrendingState();

  @override
  List<Object?> get props => [];
}

class TvTrendingInitial extends TvTrendingState {
  const TvTrendingInitial();
}

class TvTrendingLoading extends TvTrendingState {
  const TvTrendingLoading();
}

class TvTrendingLoaded extends TvTrendingState {
  final List<TvSerie> trendingList;
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;

  const TvTrendingLoaded({
    required this.trendingList,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props =>
      [trendingList, hasReachedMax, currentPage, isLoadingMore];

  /// Create a copy of this state with updated values
  TvTrendingLoaded copyWith({
    List<TvSerie>? trendingList,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return TvTrendingLoaded(
      trendingList: trendingList ?? this.trendingList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  /// Check if we can load more items
  bool get canLoadMore => !hasReachedMax && !isLoadingMore;

  /// Get the total number of loaded items
  int get totalItems => trendingList.length;

  @override
  String toString() {
    return 'TvTrendingLoaded{items: ${trendingList.length}, page: $currentPage, hasReachedMax: $hasReachedMax, isLoadingMore: $isLoadingMore}';
  }
}

class TvTrendingError extends TvTrendingState {
  final String message;

  const TvTrendingError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'TvTrendingError{message: $message}';
}
