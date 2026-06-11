import 'package:cinemind/shared/widget/card/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cinemind/shared/cubit/movie/movie_popular/movie_popular_cubit.dart';
import 'package:cinemind/shared/cubit/movie/movie_popular/movie_popular_state.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:cinemind/model/movie.dart';
import 'package:cinemind/module/detail/movie_detail_screen.dart';
import 'package:cinemind/shared/service/movie_service.dart';

class PopularMoviesScreen extends StatefulWidget {
  const PopularMoviesScreen({super.key});

  @override
  State<PopularMoviesScreen> createState() => _PopularMoviesScreenState();
}

class _PopularMoviesScreenState extends State<PopularMoviesScreen> {
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
      context.read<MoviePopularCubit>().loadMorePopularMovies();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    await context.read<MoviePopularCubit>().refreshPopularMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Popular Movies',
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
      body: BlocBuilder<MoviePopularCubit, MoviePopularState>(
        builder: (context, state) {
          if (state is MoviePopularLoading) {
            return const Center(
              child: SpinKitHourGlass(
                color: CineMindTheme.primaryRed,
                size: 50,
              ),
            );
          } else if (state is MoviePopularLoaded) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: CineMindTheme.primaryRed,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: state.popularList.length +
                    (state.isLoadingMore ? 1 : 0) +
                    (state.hasReachedMax && state.popularList.isNotEmpty
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  // Loading more indicator
                  if (state.isLoadingMore &&
                      index == state.popularList.length) {
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
                      state.popularList.isNotEmpty &&
                      index >= state.popularList.length) {
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

                  // Regular movie item
                  if (index < state.popularList.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => _navigateToMovieDetails(
                            context, state.popularList[index]),
                        child: MovieCard(
                          movie: state.popularList[index],
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            );
          } else if (state is MoviePopularError) {
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
                      context.read<MoviePopularCubit>().fetchPopularMovies();
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

  Future<void> _navigateToMovieDetails(
      BuildContext context, Movie movie) async {
    // Show loading indicator while fetching Movie details
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
      final movieDetails = await MovieService().fetchMovieById(movie.id);
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

      if (movieDetails != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(
              movie: movieDetails,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load movie details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
      print('Error fetching Movie details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load movie details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
