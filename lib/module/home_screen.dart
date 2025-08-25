import 'package:cinemind/shared/cubit/movie/movie_cubit.dart';
import 'package:cinemind/shared/cubit/movie/movie_state.dart';
import 'package:cinemind/shared/repo/movie_repo.dart';
import 'package:cinemind/shared/repo/tv_repo.dart';
import 'package:cinemind/shared/service/tv_serie_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:palette_generator/palette_generator.dart';

import '../shared/cubit/tv/tv_trending/tv_trending_cubit.dart';
import '../shared/cubit/tv/tv_trending/tv_trending_state.dart';
import '../shared/widget/card/auto_scrolling_card.dart';
import '../shared/widget/card/movie_card_horiz.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int selectedCategoryIndex = 0;
  Color currentGradientStart = const Color(0xFF1A1A2E);
  Color currentGradientEnd = const Color(0xFF16213E);
  Color targetGradientStart = const Color(0xFF1A1A2E);
  Color targetGradientEnd = const Color(0xFF16213E);
  late AnimationController _gradientController;
  late final MovieCubit _movieCubit;
  late final TvTrendingCubit _tvTrendingCubit;

  @override
  void initState() {
    super.initState();

    // Create cubits once and fetch data. Do not recreate them on rebuild.
    _movieCubit = MovieCubit(MovieRepository())..fetchAllMovies();
    _tvTrendingCubit = TvTrendingCubit(
      repo: TvRepo(
        service: TvSerieService(),
        cacheBox: Hive.box('tv_cache'),
      ),
    )..fetchTrendingList();

    _gradientController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _gradientController.addListener(() {
      setState(() {
        currentGradientStart = Color.lerp(
          currentGradientStart,
          targetGradientStart,
          _gradientController.value,
        )!;
        currentGradientEnd = Color.lerp(
          currentGradientEnd,
          targetGradientEnd,
          _gradientController.value,
        )!;
      });
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    // Close cubits created in initState
    _movieCubit.close();
    _tvTrendingCubit.close();
    super.dispose();
  }

  Future<void> _updateGradientFromImage(String imageUrl) async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        maximumColorCount: 8,
      );

      Color newStartColor = paletteGenerator.vibrantColor?.color ??
          paletteGenerator.dominantColor?.color ??
          const Color(0xFF1A1A2E);

      Color newEndColor = paletteGenerator.darkVibrantColor?.color ??
          paletteGenerator.darkMutedColor?.color ??
          const Color(0xFF16213E);

      // Make colors stronger and more vibrant
      newStartColor = Color.lerp(newStartColor, Colors.black, 0.1)!;
      newEndColor = Color.lerp(newEndColor, Colors.black, 0.2)!;

      // Update target colors and animate
      targetGradientStart = newStartColor;
      targetGradientEnd = newEndColor;

      _gradientController.reset();
      _gradientController.forward();
    } catch (e) {
      print('Error generating palette: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _movieCubit),
        BlocProvider.value(value: _tvTrendingCubit),
      ],
      child: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  currentGradientStart,
                  currentGradientStart.withOpacity(0.8),
                  currentGradientEnd,
                  currentGradientEnd.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: CustomeAppBar(),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTrendingTvSerie(),
                      const SizedBox(height: 10),
                      _buildMostPopularMovies(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar CustomeAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      toolbarHeight: 80,
      centerTitle: false,
      leading: GestureDetector(
        onTap: () {
          // TODO: Navigate to profile / login
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade800,
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Hello, Ali",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "\"Good morning, Vietnam!\"",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Navigate to wishlist
          },
          icon: const Icon(Icons.favorite),
          color: Colors.red,
          iconSize: 28,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildTrendingTvSerie() {
    return Column(
      children: [
        _sectionHeader("Trending TV Shows"),
        const SizedBox(height: 10),
        BlocBuilder<TvTrendingCubit, TvTrendingState>(
          builder: (context, state) {
            if (state is TvTrendingLoading) {
              return const SizedBox(
                height: 240, // Increased height
                child: Center(
                    child: CircularProgressIndicator(
                  color: Color(0xFF00D4FF),
                )),
              );
            } else if (state is TvTrendingLoaded) {
              if (state.trendingList.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 240, // Increased height from 200 to 240
                child: AutoScrollingTvCards(
                  tvShows: state.trendingList,
                  autoScrollDuration:
                      const Duration(seconds: 2), // 2 second auto-scroll
                  onPageChanged: (index) {
                    // Only update gradient, don't fetch new data
                    if (index < state.trendingList.length) {
                      final currentShow = state.trendingList[index];
                      final imageUrl =
                          currentShow.posterPath ?? currentShow.backdropPath;
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        _updateGradientFromImage(
                            'https://image.tmdb.org/t/p/w500$imageUrl');
                      }
                    }
                  },
                  showIndicators: false, // Hide dot indicators
                ),
              );
            } else if (state is TvTrendingError) {
              return SizedBox(
                height: 240, // Increased height
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.grey.shade400,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load TV shows',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildMostPopularMovies() {
    return Column(
      children: [
        _sectionHeader("Most Popular Movies"),
        SizedBox(
          height: 180,
          child: BlocBuilder<MovieCubit, MovieState>(
            builder: (context, state) {
              if (state is MovieLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Color(0xFF00D4FF),
                ));
              } else if (state is MovieLoaded) {
                final movies = state.popular;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: movies.length,
                  itemBuilder: (_, i) => MovieCard(movie: movies[i]),
                );
              } else if (state is MovieError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.grey.shade400,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load movies',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          GestureDetector(
            onTap: () {
              // Add navigation to see all screen
            },
            child:
                Text("See All", style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
