import 'dart:async';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class AutoScrollingTvCards extends StatefulWidget {
  final List<dynamic> tvShows; // Your list of TV shows

  const AutoScrollingTvCards({super.key, required this.tvShows});

  @override
  State<AutoScrollingTvCards> createState() => _AutoScrollingTvCardsState();
}

class _AutoScrollingTvCardsState extends State<AutoScrollingTvCards>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _dotsAnimationController;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    _dotsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (widget.tvShows.isNotEmpty) {
        int nextIndex = (_currentIndex + 1) % widget.tvShows.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _dotsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _dotsAnimationController.forward().then((_) {
                _dotsAnimationController.reverse();
              });
            },
            itemCount: widget.tvShows.length,
            itemBuilder: (context, index) {
              return TvCard(tv: widget.tvShows[index]);
            },
          ),
        ),
        const SizedBox(height: 16),
        // Animated dots indicator
        AnimatedDotsIndicator(
          currentIndex: _currentIndex,
          itemCount: widget.tvShows.length,
          animationController: _dotsAnimationController,
        ),
      ],
    );
  }
}

class AnimatedDotsIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;
  final AnimationController animationController;

  const AnimatedDotsIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            double scale = index == currentIndex
                ? 1.0 + (animationController.value * 0.3)
                : 1.0;

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == currentIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class TvCard extends StatefulWidget {
  final dynamic tv;

  const TvCard({super.key, required this.tv});

  @override
  State<TvCard> createState() => _TvCardState();
}

class _TvCardState extends State<TvCard> {
  Color _shadowColor = Colors.black26;

  @override
  void initState() {
    super.initState();
    _extractColors();
  }

  Future<void> _extractColors() async {
    try {
      final imageUrl =
          "https://image.tmdb.org/t/p/w500${widget.tv.backdropPath}";
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        maximumColorCount: 10,
      );

      if (mounted) {
        setState(() {
          _shadowColor = paletteGenerator.dominantColor?.color ??
              paletteGenerator.vibrantColor?.color ??
              Colors.black26;
        });
      }
    } catch (e) {
      // Fallback to default shadow color if extraction fails
      if (mounted) {
        setState(() {
          _shadowColor = Colors.black26;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _shadowColor.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: _shadowColor.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.network(
                "https://image.tmdb.org/t/p/w500${widget.tv.backdropPath}",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.tv,
                      size: 50,
                      color: Colors.white54,
                    ),
                  );
                },
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            // Title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.tv.name ?? "Unknown",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    if (widget.tv.firstAirDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.tv.firstAirDate.substring(0, 4), // Year only
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
