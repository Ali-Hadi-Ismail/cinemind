import 'package:cinemind/shared/theme/theme.dart';
import 'package:flutter/material.dart';

import '../../model/season.dart';
import '../../model/episode.dart';

class SeasonDetailsScreen extends StatefulWidget {
  final Season season;
  final String tvSeriesName; // To show context

  const SeasonDetailsScreen({
    super.key,
    required this.season,
    required this.tvSeriesName,
  });

  @override
  State<SeasonDetailsScreen> createState() => _SeasonDetailsScreenState();
}

class _SeasonDetailsScreenState extends State<SeasonDetailsScreen> {
  bool _liked = false;

  String _normalizeImageUrl(String? path, {bool backdrop = false}) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return backdrop
        ? 'https://image.tmdb.org/t/p/w780$path'
        : 'https://image.tmdb.org/t/p/w342$path';
  }

  void _openEpisodeDetails(Episode episode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Episode image
              if (episode.stillPath != null && episode.stillPath!.isNotEmpty)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _normalizeImageUrl(episode.stillPath),
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child:
                              Icon(Icons.tv, color: Colors.white54, size: 50),
                        ),
                      ),
                    ),
                  ),
                ),

              // Episode title
              Text(
                episode.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Episode info
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildInfoChip('Episode ${episode.episodeNumber}'),
                  if (episode.runtime != null && episode.runtime! > 0)
                    _buildInfoChip('${episode.runtime} min'),
                  if (episode.voteAverage > 0)
                    _buildInfoChip(
                        '★ ${episode.voteAverage.toStringAsFixed(1)}'),
                ],
              ),

              const SizedBox(height: 16),

              // Episode overview
              if (episode.overview.isNotEmpty) ...[
                const Text(
                  'Overview:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      episode.overview,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Close button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final season = widget.season;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              backgroundColor: const Color(0xFF1A1A2E),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context);
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _normalizeImageUrl(season.posterPath, backdrop: true)
                              .isNotEmpty
                          ? _normalizeImageUrl(season.posterPath,
                              backdrop: true)
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
                      bottom: 15,
                      left: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Season Poster
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
                                _normalizeImageUrl(season.posterPath).isNotEmpty
                                    ? _normalizeImageUrl(season.posterPath)
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
                                Text(
                                  widget.tvSeriesName,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(season.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.visible),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _buildInfoChip(_getYear(
                                        season.airDate.isNotEmpty
                                            ? season.airDate
                                            : 'Unknown')),
                                    _buildInfoChip(
                                        '${season.episodes.length} Episodes'),
                                    if (season.voteAverage > 0)
                                      _buildInfoChip(
                                          '★ ${season.voteAverage.toStringAsFixed(1)}'),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Story:",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      season.overview.isNotEmpty
                          ? season.overview
                          : 'No overview available for this season.',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Air Date:",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      season.airDate.isNotEmpty ? season.airDate : 'Unknown',
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      color: Colors.grey[700],
                    ),
                    Text(
                      "Episodes:",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),

                    // Episodes Grid
                    if (season.episodes.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8, // wider for episode stills
                        ),
                        itemCount: season.episodes.length,
                        itemBuilder: (context, index) {
                          final episode = season.episodes[index];
                          final stillUrl = episode.stillPath != null
                              ? _normalizeImageUrl(episode.stillPath)
                              : '';

                          return GestureDetector(
                            onTap: () => _openEpisodeDetails(episode),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              color: CineMindTheme.cardDark,
                              elevation: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Episode still/image
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: stillUrl.isNotEmpty
                                          ? Image.network(
                                              stillUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) =>
                                                  Container(
                                                color: Colors.grey[800],
                                                child: const Center(
                                                  child: Icon(Icons.tv,
                                                      color: Colors.white54,
                                                      size: 40),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              color: Colors.grey[800],
                                              child: const Center(
                                                child: Icon(Icons.tv,
                                                    color: Colors.white54,
                                                    size: 40),
                                              ),
                                            ),
                                    ),
                                  ),

                                  // Episode info
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Episode number and title
                                          Text(
                                            'E${episode.episodeNumber}',
                                            style: const TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Expanded(
                                            child: Text(
                                              episode.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                          // Episode metadata
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (episode.runtime != null &&
                                                  episode.runtime! > 0)
                                                Text(
                                                  '${episode.runtime}m',
                                                  style: const TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              if (episode.voteAverage > 0)
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      episode.voteAverage
                                                          .toStringAsFixed(1),
                                                      style: const TextStyle(
                                                        color: Colors.white60,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
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
                          );
                        },
                      )
                    else
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No episodes available',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
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
