import 'dart:async';
import 'package:cinemind/shared/cubit/movie/movie_cubit.dart';
import 'package:cinemind/shared/cubit/movie/movie_state.dart';
import 'package:cinemind/shared/repo/movie_repo.dart';
import 'package:cinemind/shared/repo/tv_repo.dart';
import 'package:cinemind/shared/service/tv_serie_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:palette_generator/palette_generator.dart';

import '../shared/cubit/tv/tv_top_rated/tv_popular_cubit.dart';
import '../shared/cubit/tv/tv_top_rated/tv_popular_state.dart';
import '../shared/widget/movie_card_horiz.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;
  final List<String> categories = ['All', 'Comedy', 'Animation', 'Documentary'];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              MovieCubit(MovieRepository())..fetchCategory('popular'),
        ),
        BlocProvider(
          create: (_) => TvPopularCubit(
            repo: TvRepo(
              service: TvSerieService(),
              cacheBox: Hive.box('tv_cache'),
            ),
          )..fetchPopularList(),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildFeatured(),
                const SizedBox(height: 30),
                _buildCategories(),
                const SizedBox(height: 25),
                _buildMostPopularMovies(),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.5),
              image: const DecorationImage(
                image: AssetImage('assets/profile.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, Smith',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  "Let's stream your favorite movie",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatured() {
    return Column(
      children: [
        _sectionHeader("Featured TV Shows"),
        const SizedBox(height: 10),
        BlocBuilder<TvPopularCubit, TvPopularState>(
          builder: (context, state) {
            if (state is TvPopularLoading) {
              return const SizedBox(
                height: 280,
                child: Center(
                    child: CircularProgressIndicator(
                  color: Color(0xFF00D4FF),
                )),
              );
            } else if (state is TvPopularLoaded) {
              if (state.popularList.isEmpty) return const SizedBox.shrink();
              return AutoScrollingTvCards(tvShows: state.popularList);
            } else if (state is TvPopularError) {
              return SizedBox(
                height: 280,
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

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Categories',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 35,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final isSelected = selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () => setState(() => selectedCategoryIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00D4FF)
                        : const Color(0xFF2A2A3E),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
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
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          GestureDetector(
            onTap: () {
              // Add navigation to see all screen
            },
            child: const Text("See All",
                style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// Enhanced Auto-Scrolling TV Cards with Fixed Infinite Scroll
class AutoScrollingTvCards extends StatefulWidget {
  final List<dynamic> tvShows;

  const AutoScrollingTvCards({super.key, required this.tvShows});

  @override
  State<AutoScrollingTvCards> createState() => _AutoScrollingTvCardsState();
}

class _AutoScrollingTvCardsState extends State<AutoScrollingTvCards>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _dotsAnimationController;
  late AnimationController _fadeController;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    // Start from middle to allow infinite scroll in both directions
    int initialPage = widget.tvShows.length * 100;
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: initialPage,
    );
    _currentIndex = initialPage % widget.tvShows.length;

    _dotsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController.forward();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (widget.tvShows.isNotEmpty && !_userInteracting && mounted) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _onUserInteraction() {
    setState(() => _userInteracting = true);
    _autoScrollTimer?.cancel();

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _userInteracting = false);
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _dotsAnimationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        children: [
          SizedBox(
            height: 280,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  _onUserInteraction();
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index % widget.tvShows.length;
                  });
                  _dotsAnimationController.forward().then((_) {
                    _dotsAnimationController.reverse();
                  });
                },
                // Infinite scroll
                itemBuilder: (context, index) {
                  final tvIndex = index % widget.tvShows.length;
                  return TvCard(tv: widget.tvShows[tvIndex]);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedProgressBar(
            currentIndex: _currentIndex,
            itemCount: widget.tvShows.length,
            animationController: _dotsAnimationController,
          ),
        ],
      ),
    );
  }
}

// Fixed Animated Progress Bar with Left-to-Right Animation
class AnimatedProgressBar extends StatelessWidget {
  final int currentIndex;
  final int itemCount;
  final AnimationController animationController;

  const AnimatedProgressBar({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    // Show max 5 dots, properly positioned
    int maxDots = itemCount > 5 ? 5 : itemCount;
    int startIndex = 0;

    if (itemCount > 5) {
      if (currentIndex <= 2) {
        // Show first 5 dots (0, 1, 2, 3, 4)
        startIndex = 0;
      } else if (currentIndex >= itemCount - 2) {
        // Show last 5 dots
        startIndex = itemCount - 5;
      } else {
        // Show middle 5 dots centered around current
        startIndex = currentIndex - 2;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxDots, (index) {
          int actualIndex = startIndex + index;
          bool isActive = actualIndex == currentIndex;

          return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white.withOpacity(0.3),
                ),
                child: Stack(
                  children: [
                    // Background bar
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    // Animated progress bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 40 : 0,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFF00D4FF).withOpacity(0.8),
                            const Color(0xFF00D4FF),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Enhanced TV Card with Top/Bottom Neon Glow
class TvCard extends StatefulWidget {
  final dynamic tv;

  const TvCard({super.key, required this.tv});

  @override
  State<TvCard> createState() => _TvCardState();
}

class _TvCardState extends State<TvCard> with TickerProviderStateMixin {
  Color _glowColor = const Color(0xFF00D4FF);
  late AnimationController _shimmerController;
  late AnimationController _glowController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _shimmerController.repeat();
    _glowController.repeat(reverse: true);
    _extractColors();
  }

  Future<void> _extractColors() async {
    try {
      final backdropPath = widget.tv.backdropPath ?? widget.tv.posterPath;
      if (backdropPath != null) {
        final imageUrl = "https://image.tmdb.org/t/p/w500$backdropPath";
        final PaletteGenerator paletteGenerator =
            await PaletteGenerator.fromImageProvider(
          NetworkImage(imageUrl),
          maximumColorCount: 20,
        );

        if (mounted) {
          setState(() {
            _glowColor = paletteGenerator.vibrantColor?.color ??
                paletteGenerator.lightVibrantColor?.color ??
                paletteGenerator.dominantColor?.color ??
                const Color(0xFF00D4FF);
            _isLoading = false;
          });
          _shimmerController.stop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _glowColor = const Color(0xFF00D4FF);
          _isLoading = false;
        });
        _shimmerController.stop();
      }
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backdropPath = widget.tv.backdropPath ?? widget.tv.posterPath;

    return Container(
      width: 320,
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          double glowIntensity = 0.2 + (_glowController.value * 0.3);

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                // Top neon glow
                BoxShadow(
                  color: _glowColor.withOpacity(glowIntensity * 0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, -8),
                ),
                // Bottom neon glow
                BoxShadow(
                  color: _glowColor.withOpacity(glowIntensity * 0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                // Subtle side glow
                BoxShadow(
                  color: _glowColor.withOpacity(glowIntensity * 0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF0F0F1A),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background Image
                    if (backdropPath != null)
                      Positioned.fill(
                        child: Image.network(
                          "https://image.tmdb.org/t/p/w500$backdropPath",
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildShimmerEffect();
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildErrorPlaceholder();
                          },
                        ),
                      )
                    else
                      _buildErrorPlaceholder(),

                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.4, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.tv.name ?? widget.tv.title ?? "Unknown",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (widget.tv.firstAirDate != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.tv.firstAirDate.substring(0, 4),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A2E),
                _glowColor.withOpacity(0.2),
                const Color(0xFF1A1A2E),
              ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: _glowColor,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF0F0F1A),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv,
              size: 48,
              color: _glowColor.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'No Image Available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
