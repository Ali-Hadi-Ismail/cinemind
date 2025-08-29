import 'package:cinemind/shared/service/movie_service.dart';
import 'package:cinemind/shared/shared_preference.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../model/cast.dart';
import '../../model/movie.dart';
import '../../shared/widget/image_full_screen.dart';
import 'actor_detail_screen.dart';

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
  final prefs = CustomeShared();
  bool _liked = false;
  List<Cast> cast = [];
  @override
  @override
  void initState() {
    super.initState();
    _loadLiked();
    _loadCast();
  }

  void _loadLiked() async {
    bool liked = await prefs.isMovieFavorite(widget.movie.id);
    setState(() => _liked = liked);
  }

  void _loadCast() async {
    final data = await MovieService().getCastByMovieById(widget.movie.id);
    setState(() {
      cast = data;
    });
  }

  String _normalizeImageUrl(String path, {bool backdrop = false}) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return backdrop
        ? 'https://image.tmdb.org/t/p/w780$path'
        : 'https://image.tmdb.org/t/p/w342$path';
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
                    Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
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
                            child: GestureDetector(
                              onTap: () {
                                if (_normalizeImageUrl(movie.posterPath)
                                    .isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullscreenImagePage(
                                        imageUrl: _normalizeImageUrl(
                                            movie.posterPath),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _normalizeImageUrl(movie.posterPath)
                                          .isNotEmpty
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
                          ),
                          const SizedBox(width: 20),
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
                          IconButton(
                            onPressed: () async {
                              setState(() => _liked = !_liked);

                              prefs.toggleFavoriteMovie(movie.id);
                            },
                            iconSize: 36,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: _liked
                                  ? Icon(Icons.favorite,
                                      key: ValueKey<bool>(_liked),
                                      color: Colors.redAccent)
                                  : Icon(Icons.favorite_border,
                                      key: ValueKey<bool>(_liked),
                                      color: Colors.white),
                            ),
                          ).animate(onPlay: (controller) {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (movie.tagline.isNotEmpty) ...[
                      Center(
                        child: Text(
                          movie.tagline,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      'Story Line',
                      style: Theme.of(context).textTheme.headlineMedium,
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
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.headlineMedium,
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
                    if (movie.genres.isNotEmpty) ...[
                      Text('Genres',
                          style: Theme.of(context).textTheme.headlineMedium),
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
                    if (movie.productionCompanies.isNotEmpty) ...[
                      Text(
                        'Production Companies',
                        style: Theme.of(context).textTheme.headlineMedium,
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
                      Divider(),
                      Text(
                        'Cast',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, childAspectRatio: 0.6),
                        itemCount: cast.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          Cast castPerson = cast[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CastDetailsScreen(castId: castPerson.id),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.blueGrey[8001],
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      castPerson.profilePath != null
                                          ? "https://image.tmdb.org/t/p/w185${castPerson.profilePath}"
                                          : "https://via.placeholder.com/150x225?text=No+Image",
                                      width: 100,
                                      height: 140,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) =>
                                          const Icon(
                                        Icons.person,
                                        color: Colors.white54,
                                        size: 100,
                                      ),
                                    ),
                                  ),
                                  Text(castPerson.name),
                                ],
                              ),
                            ),
                          );
                        },
                      )
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
        style: Theme.of(context).textTheme.headlineMedium,
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
