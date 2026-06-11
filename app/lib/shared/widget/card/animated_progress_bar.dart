// Fixed Animated Progress Bar with Left-to-Right Animation
import 'package:flutter/material.dart';

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
