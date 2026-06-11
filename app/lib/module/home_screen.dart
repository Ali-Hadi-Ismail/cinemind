import 'package:cinemind/module/detail/movie_detail_screen.dart';
import 'package:cinemind/model/movie.dart';
import 'package:cinemind/module/detail/tv_serie_detail_screen.dart';
import 'package:cinemind/module/impulse/favorite_screen.dart';
import 'package:cinemind/module/impulse/popular_screen.dart';
import 'package:cinemind/module/impulse/trending_screen.dart';
import 'package:cinemind/module/impulse/watchlist_screen.dart';
import 'package:cinemind/shared/cubit/movie/movie_cubit.dart';
import 'package:cinemind/shared/cubit/movie/movie_popular/movie_popular_cubit.dart';
import 'package:cinemind/shared/cubit/movie/movie_state.dart';
import 'package:cinemind/shared/repo/movie_repo.dart';
import 'package:cinemind/shared/repo/tv_repo.dart';
import 'package:cinemind/shared/service/tv_serie_service.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:palette_generator/palette_generator.dart';

import '../shared/cubit/movie/movie_trending/movie_trending_cubit.dart';
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
  late final MoviePopularCubit _moviePopularCubit;
  late final TvTrendingCubit _tvTrendingCubit;
  late final MovieTrendingCubit _movieTrendingCubit;

  // Cache palettes per image url to avoid recomputation
  final Map<String, List<Color>> _paletteCache = {};
  String? _lastPaletteImage;

  @override
  void initState() {
    super.initState();

    // Create cubits once and fetch data. Do not recreate them on rebuild.
    _movieCubit = MovieCubit(MovieRepository())..fetchAllMovies();
    _tvTrendingCubit = TvTrendingCubit(repo: TvRepo(service: TvSerieService()))
      ..fetchTrendingList();
    _movieTrendingCubit = MovieTrendingCubit(repo: MovieRepository())
      ..fetchTrending('week');
    _moviePopularCubit = MoviePopularCubit(repo: MovieRepository())
      ..fetchPopularMovies();
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
    _movieTrendingCubit.close();
    super.dispose();
  }

  Future<void> _updateGradientFromImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    // If we already generated a palette for this image, reuse it
    if (_lastPaletteImage == imageUrl && _paletteCache.containsKey(imageUrl)) {
      final colors = _paletteCache[imageUrl]!;
      targetGradientStart = colors[0];
      targetGradientEnd = colors[1];
      _gradientController.reset();
      _gradientController.forward();
      return;
    }

    if (_paletteCache.containsKey(imageUrl)) {
      final colors = _paletteCache[imageUrl]!;
      targetGradientStart = colors[0];
      targetGradientEnd = colors[1];
      _lastPaletteImage = imageUrl;
      _gradientController.reset();
      _gradientController.forward();
      return;
    }

    try {
      // Keep the sampled size and color count low for performance
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        maximumColorCount: 4,
        size: const Size(200, 100),
      );

      Color newStartColor = paletteGenerator.vibrantColor?.color ??
          paletteGenerator.dominantColor?.color ??
          const Color(0xFF1A1A2E);

      Color newEndColor = paletteGenerator.darkVibrantColor?.color ??
          paletteGenerator.darkMutedColor?.color ??
          const Color(0xFF16213E);

      // Make colors slightly stronger
      newStartColor = Color.lerp(newStartColor, Colors.black, 0.1)!;
      newEndColor = Color.lerp(newEndColor, Colors.black, 0.15)!;

      // Cache and apply
      _paletteCache[imageUrl] = [newStartColor, newEndColor];
      _lastPaletteImage = imageUrl;
      targetGradientStart = newStartColor;
      targetGradientEnd = newEndColor;
      _gradientController.reset();
      _gradientController.forward();
    } catch (e) {
      print('Error generating palette: $e');
    }
  }

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _movieCubit),
        BlocProvider.value(value: _tvTrendingCubit),
        BlocProvider.value(value: _movieTrendingCubit),
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
              appBar: customeAppBar(),
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTrendingTvSerie(),
                    _buildMostPopularMovies(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar customeAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      toolbarHeight: 80,
      centerTitle: false,
      leading: GestureDetector(
        onTap: () {},
        child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade800,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(70),
                  child: Image.network(
                    user!.photoURL!,
                    width: 70,
                    height: 40,
                    fit: BoxFit.cover,
                  )),
            )),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Hello ${user?.displayName}",
              style: Theme.of(context).textTheme.bodyLarge),
          SizedBox(height: 4),
          Text("\"Good morning, Vietnam!\"",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontSize: 16)),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return FavoriteScreen();
                },
              ),
            );
          },
          icon: const Icon(Icons.favorite),
          color: Colors.red,
          iconSize: 28,
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return WatchlistScreen();
                },
              ),
            );
          },
          icon: const Icon(Icons.bookmark),
          color: Colors.amber,
          iconSize: 28,
        ),
      ],
    );
  } // Replace your _buildTrendingTvSerie method in home_screen.dart with this:

  Widget _buildTrendingTvSerie() {
    return Column(
      children: [
        _sectionHeader("Trending TV Shows"),
        const SizedBox(height: 10),
        BlocBuilder<TvTrendingCubit, TvTrendingState>(
          buildWhen: (previous, current) {
            // Only rebuild when the state actually changes
            if (previous is TvTrendingLoaded && current is TvTrendingLoaded) {
              return previous.trendingList != current.trendingList ||
                  previous.isLoadingMore != current.isLoadingMore;
            }
            return previous != current;
          },
          builder: (context, state) {
            if (state is TvTrendingLoading) {
              return SizedBox(
                height: 240,
                child: Center(
                    child: SpinKitHourGlass(
                  color: CineMindTheme.primaryRed,
                )),
              );
            } else if (state is TvTrendingLoaded) {
              if (state.trendingList.isEmpty) return const SizedBox.shrink();

              return SizedBox(
                height: 240,
                child: AutoScrollingTvCards(
                  tvShows: state.trendingList,
                  autoScrollDuration: const Duration(seconds: 5),
                  onCardTap: (index) async {
                    if (index >= state.trendingList.length) return;

                    final tvShow = state.trendingList[index];

                    // Show loading dialog
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
                      final tvSerieToPass =
                          await TvSerieService().fetchTvSerieByID(tvShow.id);
                      Navigator.of(context, rootNavigator: true)
                          .pop(); // Close loading dialog

                      if (tvSerieToPass != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TvDetailsScreen(
                              tvSerie: tvSerieToPass,
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
                      Navigator.of(context, rootNavigator: true)
                          .pop(); // Close loading dialog
                      print(
                          'Error fetching TV series with ID: ${tvShow.id}, error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to load TV show details'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  onPageChanged: (index) {
                    if (index < state.trendingList.length) {
                      final currentShow = state.trendingList[index];
                      final imageUrl = currentShow.backdropPath;
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        _updateGradientFromImage(
                            'https://image.tmdb.org/t/p/w780$imageUrl');
                      }
                    }
                  },
                  showIndicators: false,
                ),
              );
            } else if (state is TvTrendingError) {
              return SizedBox(
                height: 240,
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
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          context.read<TvTrendingCubit>().fetchTrendingList();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CineMindTheme.primaryRed,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
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

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          GestureDetector(
            onTap: () {
              if (title == "Trending TV Shows") {
                // Pass the existing cubits to TrendingScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: _tvTrendingCubit),
                        BlocProvider.value(value: _movieTrendingCubit),
                      ],
                      child: TrendingScreen(),
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: _moviePopularCubit),
                      ],
                      child: PopularMoviesScreen(),
                    ),
                  ),
                );
              }
            },
            child:
                Text("See All", style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildMostPopularMovies() {
    return Column(
      children: [
        _sectionHeader("Most Popular Movies"),
        SizedBox(
          height: 180,
          child: BlocBuilder<MovieCubit, MovieState>(
            buildWhen: (previous, current) {
              // Prevent transient MovieLoading from clearing existing MovieLoaded UI
              if (current is MovieLoading && previous is MovieLoaded) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state is MovieLoading) {
                return const Center(
                    child: SpinKitHourGlass(
                  color: CineMindTheme.primaryRed,
                ));
              } else if (state is MovieLoaded) {
                final movies = state.popular;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: movies.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () async {
                      // Show loading indicator while fetching movie details
                      showDialog(
                        context: context,
                        builder: (context) => const Center(
                          child: SpinKitHourGlass(
                            color: CineMindTheme.primaryRed,
                          ),
                        ),
                      );
                      Movie? movie;
                      try {
                        movie = await context
                            .read<MovieCubit>()
                            .fetchMovieByIdFromAPI(movies[i].id);
                      } catch (e) {
                        // If detail fetch fails, fall back to the list item so navigation still works
                        print(
                            'Error fetching movie details for id ${movies[i].id}  error is : $e');
                        movie = movies[i];
                      }
                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailsScreen(movie: movie!),
                        ),
                      );
                    },
                    child: MovieCardPoster(
                      movie: movies[i],
                    ),
                  ),
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
}
