import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../model/tv_series.dart';
import '../../shared/repo/tv_repo.dart';
import '../../shared/service/tv_serie_service.dart';

class TvDetailsScreen extends StatefulWidget {
  final TvSerie tvSerie;

  const TvDetailsScreen({
    super.key,
    required this.tvSerie,
  });

  @override
  State<TvDetailsScreen> createState() => _TvDetailsScreenState();
}

class _TvDetailsScreenState extends State<TvDetailsScreen> {
  late final Future<List<String>> _imagesFuture;
  bool _liked = false;
  final TvRepo tvRepo = TvRepo(
    service: TvSerieService(),
  );

  @override
  void initState() {
    super.initState();
    _imagesFuture = _loadImages();
  }

  Future<List<String>> _loadImages() async {
    final images = await tvRepo.getTvImages(widget.tvSerie.id);
    return images
        .map((path) => _normalizeImageUrl(path))
        .where((url) => url.isNotEmpty)
        .toList();
  }

  String _normalizeImageUrl(String? path, {bool backdrop = false}) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return backdrop
        ? 'https://image.tmdb.org/t/p/w780$path'
        : 'https://image.tmdb.org/t/p/w342$path';
  }

  void _openGallery(List<String> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black,
          child: SafeArea(
            child: PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: images.length,
              itemBuilder: (context, index) => InteractiveViewer(
                child: Center(
                  child: Image.network(
                    images[index].isNotEmpty
                        ? images[index]
                        : 'https://via.placeholder.com/500x300?text=No+Image',
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (context, error, stack) => const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.white70, size: 64)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tv = widget.tvSerie;
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
                onPressed: () {
                  // Dismiss keyboard if open
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context);
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _normalizeImageUrl(tv.backdropPath, backdrop: true)
                              .isNotEmpty
                          ? _normalizeImageUrl(tv.backdropPath, backdrop: true)
                          : 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=500&h=600&fit=crop',
                      fit: BoxFit.cover,
                      loadingBuilder: (c, child, progress) => progress == null
                          ? child
                          : Container(color: Colors.grey[850]),
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[850],
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.white24, size: 64),
                        ),
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
                          // Poster Image
                          Container(
                            width: 120,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 10,
                                    offset: Offset(0, 5))
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _normalizeImageUrl(tv.posterPath).isNotEmpty
                                    ? _normalizeImageUrl(tv.posterPath)
                                    : 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=300&h=450&fit=crop',
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(Icons.broken_image,
                                        color: Colors.white54, size: 40),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tv.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _buildInfoChip(_getYear(
                                        tv.firstAirDate.isNotEmpty
                                            ? tv.firstAirDate
                                            : 'Unknown')),
                                    _buildInfoChip(
                                        '${tv.seasons.length} Seasons'),
                                    _buildInfoChip(
                                        '${tv.numberOfEpisodes} Episodes'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _liked = !_liked),
                            iconSize: 36,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: _liked
                                  ? const Icon(Icons.favorite,
                                      key: ValueKey(true),
                                      color: Colors.redAccent)
                                  : const Icon(Icons.favorite_border,
                                      key: ValueKey(false),
                                      color: Colors.white),
                            ),
                          ),
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
                    FutureBuilder<List<String>>(
                      future: _imagesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                              height: 120,
                              child:
                                  Center(child: CircularProgressIndicator()));
                        }

                        final images = snapshot.data ?? [];
                        if (images.isEmpty) return const SizedBox.shrink();

                        const int maxVisible = 6;
                        final visible = images.take(maxVisible).toList();
                        final hasMore = images.length > maxVisible;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Photos',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
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
                                    return GestureDetector(
                                      onTap: () => _openGallery(images, 0),
                                      child: Container(
                                        width: 110,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
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

                                  return GestureDetector(
                                    onTap: () => _openGallery(images, i),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(visible[i],
                                          width: 90,
                                          height: 140,
                                          fit: BoxFit.cover),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      );

  String _getYear(String date) =>
      date.isEmpty ? 'Unknown' : date.substring(0, 4);
}
