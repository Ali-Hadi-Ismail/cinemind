import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../module/home_screen.dart';
import 'animated_progress_bar.dart';
import 'tv_card.dart';

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
