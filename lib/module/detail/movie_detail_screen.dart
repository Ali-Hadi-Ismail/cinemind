import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../model/movie.dart';
import '../../shared/repo/movie_repo.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late final MovieRepository _movieRepo;
  late final Future<List<String>> _imagesFuture;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _movieRepo = MovieRepository();
    _imagesFuture = _movieRepo.getMovieImages(widget.movie.id);
  }

  String _normalizeImageUrl(String path, {bool backdrop = false}) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    // Use TMDb recommended sizes
    return backdrop
        ? 'https://image.tmdb.org/t/p/w780$path'
        : 'https://image.tmdb.org/t/p/w342$path';
  }

  void _openGallery(List<String> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black,
            child: SafeArea(
              child: PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final url = images[index];
                  return InteractiveViewer(
                    child: Center(
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stack) => const Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.white70, size: 64),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 400,
              pinned: true,
              backgroundColor: const Color(0xFF1A1A2E),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background poster/backdrop image (use Image.network for loading/error handling)
                    Positioned.fill(
                      child: Image.network(
                        _normalizeImageUrl(movie.backdropPath, backdrop: true)
                                .isNotEmpty
                            ? _normalizeImageUrl(movie.backdropPath,
                                backdrop: true)
                            : 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=500&h=600&fit=crop',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(color: Colors.grey[850]);
                        },
                        errorBuilder: (context, error, stack) {
                          return Container(
                            color: Colors.grey[850],
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.white24, size: 64),
                            ),
                          );
                        },
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF1A1A2E).withOpacity(0.7),
                            const Color(0xFF1A1A2E),
                          ],
                          stops: const [0.0, 0.7, 1.0],
                        ),
                      ),
                    ),
                    // Movie poster and title
                    Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Movie poster
                          Container(
                            width: 120,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _normalizeImageUrl(movie.posterPath).isNotEmpty
                                    ? _normalizeImageUrl(movie.posterPath)
                                    : 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=300&h=450&fit=crop',
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(color: Colors.grey[800]);
                                },
                                errorBuilder: (context, error, stack) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: Icon(Icons.broken_image,
                                          color: Colors.white54, size: 40),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Movie info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _buildInfoChip(_getYear(movie.releaseDate)),
                                    _buildInfoChip(
                                        _formatRuntime(movie.runtime)),
                                    if (movie.genres.isNotEmpty)
                                      _buildInfoChip(movie.genres.first.name),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Like button near the title area
                          IconButton(
                            onPressed: () {
                              setState(() => _liked = !_liked);
                            },
                            iconSize: 36,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              // Use a ValueKey tied to the boolean so the new child is
                              // always a distinct keyed widget when _liked changes.
                              child: _liked
                                  ? Icon(Icons.favorite,
                                      key: ValueKey<bool>(_liked),
                                      color: Colors.redAccent)
                                  : Icon(Icons.favorite_border,
                                      key: ValueKey<bool>(_liked),
                                      color: Colors.white),
                            ),
                          ).animate(onPlay: (controller) {
                            /* no-op: animated via AnimatedSwitcher */
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image gallery (thumbnails) similar to TMDb
                    FutureBuilder<List<String>>(
                      future: _imagesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 120,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        // Repo now returns full URLs already. Still normalize in case.
                        final raw = snapshot.data!
                            .map((p) => _normalizeImageUrl(p))
                            .where((p) => p.isNotEmpty)
                            .toList();

                        // Deduplicate while preserving order
                        final images = <String>[];
                        final seen = <String>{};
                        for (var u in raw) {
                          if (seen.add(u)) images.add(u);
                        }

                        if (images.isEmpty) return const SizedBox.shrink();

                        const int maxVisible = 6;
                        final visible = images.take(maxVisible).toList();
                        final hasMore = images.length > maxVisible;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Photos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(right: 8),
                                itemCount: visible.length + (hasMore ? 1 : 0),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, i) {
                                  if (i >= visible.length && hasMore) {
                                    // 'See all' tile
                                    return GestureDetector(
                                      onTap: () => _openGallery(images, 0),
                                      child: Container(
                                        width: 110,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.photo_library,
                                                  color: Colors.white70),
                                              SizedBox(height: 6),
                                              Text('See all',
                                                  style: TextStyle(
                                                      color: Colors.white70)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final url = visible[i];
                                  // Determine approximate orientation from TMDb size token
                                  final isLandscape = url.contains('/w300') ||
                                      url.contains('/w780') ||
                                      url.contains('/w300');
                                  final width = isLandscape ? 140.0 : 90.0;
                                  final height = isLandscape ? 86.0 : 140.0;

                                  return GestureDetector(
                                    onTap: () => _openGallery(images, i),
                                    child: Container(
                                      width: width,
                                      height: height,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[800],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.cover,
                                          width: width,
                                          height: height,
                                          loadingBuilder: (c, child, p) {
                                            if (p == null) return child;
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                          errorBuilder: (c, e, s) => Container(
                                            color: Colors.grey[850],
                                            child: const Center(
                                              child: Icon(Icons.broken_image,
                                                  color: Colors.white24),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),

                    // Tagline (if available)
                    if (movie.tagline.isNotEmpty) ...[
                      Center(
                        child: Text(
                          movie.tagline,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Story Line section
                    const Text(
                      'Story Line',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movie.overview,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Movie Details
                    const Text(
                      'Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Release Date', movie.releaseDate),
                    _buildDetailRow('Runtime', '${movie.runtime} minutes'),
                    _buildDetailRow('Original Language',
                        movie.originalLanguage.toUpperCase()),
                    if (movie.budget > 0)
                      _buildDetailRow(
                          'Budget', '\$${_formatCurrency(movie.budget)}'),
                    if (movie.revenue > 0)
                      _buildDetailRow(
                          'Revenue', '\$${_formatCurrency(movie.revenue)}'),

                    const SizedBox(height: 30),

                    // Genres
                    if (movie.genres.isNotEmpty) ...[
                      const Text(
                        'Genres',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: movie.genres
                            .map((genre) => _buildGenreChip(genre.name))
                            .toList(),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Production Companies
                    if (movie.productionCompanies.isNotEmpty) ...[
                      const Text(
                        'Production Companies',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...movie.productionCompanies.map(
                        (company) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            company.name,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildGenreChip(String genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Text(
        genre,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getYear(String releaseDate) {
    if (releaseDate.isEmpty) return 'Unknown';
    return releaseDate.substring(0, 4);
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }

  String _formatRuntime(int minutes) {
    if (minutes <= 0) return 'Unknown';
    final hrs = minutes ~/ 60;
    final mins = minutes % 60;
    if (hrs > 0) {
      return mins > 0 ? '${hrs}h ${mins}m' : '${hrs}h';
    }
    return '${mins}m';
  }
}
