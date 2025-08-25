// Updated TvCard with color callback
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class TvCard extends StatefulWidget {
  final dynamic tv;
  final ValueChanged<Color>? onColorExtracted;

  const TvCard({
    super.key,
    required this.tv,
    this.onColorExtracted,
  });

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

          // Pass color to parent widget
          if (widget.onColorExtracted != null) {
            widget.onColorExtracted!(_glowColor);
          }

          _shimmerController.stop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _glowColor = const Color(0xFF00D4FF);
          _isLoading = false;
        });

        // Pass default color to parent
        if (widget.onColorExtracted != null) {
          widget.onColorExtracted!(_glowColor);
        }

        _shimmerController.stop();
      }
    }
  }

  // Rest of TvCard implementation stays the same
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
                BoxShadow(
                  color: _glowColor.withOpacity(glowIntensity * 0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, -8),
                ),
                BoxShadow(
                  color: _glowColor.withOpacity(glowIntensity * 0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
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
                    if (backdropPath != null)
                      Positioned.fill(
                        child: Image.network(
                          "https://image.tmdb.org/t/p/w500$backdropPath",
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(color: Colors.grey[800]);
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: Center(
                                child: Icon(
                                  Icons.tv,
                                  color: _glowColor.withOpacity(0.6),
                                  size: 48,
                                ),
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
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Title
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Text(
                        widget.tv.name ?? widget.tv.title ?? "Unknown",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
}
