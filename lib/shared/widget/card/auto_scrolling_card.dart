import 'package:flutter/material.dart';
import 'dart:async';

class AutoScrollingTvCards extends StatefulWidget {
  final List tvShows; // Replace with your TV show model type
  final Function(int)? onPageChanged;
  final bool showIndicators;
  final Duration autoScrollDuration;

  const AutoScrollingTvCards({
    super.key,
    required this.tvShows,
    this.onPageChanged,
    this.showIndicators = true,
    this.autoScrollDuration = const Duration(seconds: 3),
  });

  @override
  State<AutoScrollingTvCards> createState() => _AutoScrollingTvCardsState();
}

class _AutoScrollingTvCardsState extends State<AutoScrollingTvCards> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.8, // Slightly smaller for better view
    );

    // Start auto-scrolling
    _startAutoScroll();

    // Trigger initial gradient update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onPageChanged != null && widget.tvShows.isNotEmpty) {
        widget.onPageChanged!(0);
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_userInteracting &&
          _pageController.hasClients &&
          widget.tvShows.isNotEmpty &&
          mounted) {
        final nextIndex = ((_currentIndex + 1) % widget.tvShows.length).toInt();
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _stopAutoScroll() {
    setState(() => _userInteracting = true);
    _autoScrollTimer?.cancel();
  }

  void _restartAutoScroll() {
    if (!mounted) return;

    // Reset user interaction state after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _userInteracting = false);
        // Start auto-scroll after user has finished interaction
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_userInteracting) {
            _startAutoScroll();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) =>
          _stopAutoScroll(), // Stop auto-scroll when user interacts
      onTapUp: (_) => _restartAutoScroll(), // Restart after interaction
      onPanStart: (_) => _stopAutoScroll(),
      onPanEnd: (_) => _restartAutoScroll(),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                if (widget.onPageChanged != null) {
                  widget.onPageChanged!(index);
                }
              },
              itemCount: widget.tvShows.length,
              itemBuilder: (context, index) {
                final show = widget.tvShows[index];
                final isActive = index == _currentIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: isActive ? 0 : 16,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isActive ? 0.5 : 0.2),
                          blurRadius: isActive ? 24.0 : 12.0,
                          spreadRadius: isActive ? 2.0 : 0.0,
                          offset: Offset(0, isActive ? 12.0 : 6.0),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background image
                          Image.network(
                            'https://image.tmdb.org/t/p/w500${show.backdropPath ?? ''}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade800,
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              );
                            },
                          ),
                          // Stronger gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.8),
                                ],
                                stops: const [0.3, 0.6, 1.0],
                              ),
                            ),
                          ),
                          // Content
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  show.name ?? show.title ?? 'Unknown Title',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // Add year below title
                                Text(
                                  _extractYear(show.firstAirDate ??
                                      show.releaseDate ??
                                      ''),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Conditionally show indicators
          if (widget.showIndicators) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.tvShows.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color(0xFF00D4FF)
                        : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _extractYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Unknown Year';
    }
    try {
      return dateString.split('-')[0];
    } catch (e) {
      return 'Unknown Year';
    }
  }
}
