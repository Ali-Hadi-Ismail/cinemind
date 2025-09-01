import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cinemind/shared/cubit/tv/tv_trending/tv_trending_cubit.dart';
import 'package:cinemind/shared/cubit/tv/tv_trending/tv_trending_state.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:cinemind/model/tv_series.dart';
import 'package:cinemind/module/detail/tv_serie_detail_screen.dart';
import 'package:cinemind/shared/service/tv_serie_service.dart';

import '../../shared/widget/card/tv_card_poster.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TvTrendingCubit>().loadMoreTrending();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    await context.read<TvTrendingCubit>().refreshTrendingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Trending TV Shows',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: BlocBuilder<TvTrendingCubit, TvTrendingState>(
        builder: (context, state) {
          if (state is TvTrendingLoading) {
            return const Center(
              child: SpinKitHourGlass(
                color: CineMindTheme.primaryRed,
                size: 50,
              ),
            );
          } else if (state is TvTrendingLoaded) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: CineMindTheme.primaryRed,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.trendingList.length +
                    (state.isLoadingMore ? 1 : 0) +
                    (state.hasReachedMax && state.trendingList.isNotEmpty
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  // Loading more indicator
                  if (state.isLoadingMore &&
                      index == state.trendingList.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SpinKitThreeBounce(
                          color: CineMindTheme.primaryRed,
                          size: 24,
                        ),
                      ),
                    );
                  }

                  // End reached indicator
                  if (state.hasReachedMax &&
                      state.trendingList.isNotEmpty &&
                      index >= state.trendingList.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'You\'ve reached the end!',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ),
                    );
                  }

                  // Regular TV show item
                  if (index < state.trendingList.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => _navigateToTvDetails(
                            context, state.trendingList[index]),
                        child: TvSerieCard(
                          tvSerie: state.trendingList[index],
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            );
          } else if (state is TvTrendingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.grey.shade400,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey.shade400,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TvTrendingCubit>().fetchTrendingList();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CineMindTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _navigateToTvDetails(
      BuildContext context, TvSerie tvShow) async {
    // Show loading indicator while fetching TV show details
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: SpinKitHourGlass(
          color: CineMindTheme.primaryRed,
        ),
      ),
    );

    try {
      final tvSerieDetails = await TvSerieService().fetchTvSerieByID(tvShow.id);
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

      if (tvSerieDetails != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TvDetailsScreen(
              tvSerie: tvSerieDetails,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load TV show details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
      print('Error fetching TV show details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load TV show details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
