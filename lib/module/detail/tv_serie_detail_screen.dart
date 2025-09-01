import 'package:cinemind/module/detail/season_detail_screen.dart';
import 'package:cinemind/shared/service/favorite_service.dart';
import 'package:cinemind/shared/service/watchlist_service.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../model/season.dart';
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
  late bool _liked;
  late bool _inWatchList;
  bool isLoadingLike = true;
  bool isLoadingWatchList = true;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final TvRepo tvRepo = TvRepo(
    service: TvSerieService(),
  );

  void _loadLiked() async {
    bool liked = await FavoriteService()
        .checkIfFavorite(userId, widget.tvSerie.id.toString());
    setState(() {
      _liked = liked;
      isLoadingLike = false;
    });
  }

  void _loadingWatchList() async {
    bool isInWatchList = await WatchlistService().checkIfWatchList(
      widget.tvSerie.id.toString(),
      userId,
    );
    setState(() {
      _inWatchList = isInWatchList;
      isLoadingWatchList = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _imagesFuture = _loadImages();
    _loadLiked();
    _loadingWatchList();
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

  void _navigateToSeasonDetail(Season season, int seasonNumber) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: SpinKitHourGlass(color: Colors.redAccent),
        ),
      );

      // Fetch detailed season info with episodes
      final Season? seasonDetail = await TvSerieService()
          .fetchTvSerieSeason(widget.tvSerie.id, seasonNumber);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (seasonDetail != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeasonDetailsScreen(
              season: seasonDetail,
              tvSeriesName: widget.tvSerie.name,
            ),
          ),
        );
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load season details'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tv = widget.tvSerie;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: (isLoadingLike || isLoadingWatchList)
          ? Center(
              child: SpinKitHourGlass(color: CineMindTheme.primaryRed),
            )
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 350,
                    pinned: true,
                    backgroundColor: const Color(0xFF1A1A2E),
                    leading: IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
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
                                ? _normalizeImageUrl(tv.backdropPath,
                                    backdrop: true)
                                : 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=500&h=600&fit=crop',
                            fit: BoxFit.cover,
                            loadingBuilder: (c, child, progress) =>
                                progress == null
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
                                      _normalizeImageUrl(tv.posterPath)
                                              .isNotEmpty
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(tv.name,
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
                                  onPressed: () {
                                    setState(() {
                                      (_liked)
                                          ? FavoriteService().removeFavorite(
                                              userId,
                                              tv.id.toString(),
                                            )
                                          : FavoriteService().addFavorite(
                                              userId, tv.id.toString(), "tv");
                                      _liked = !_liked;
                                    });
                                  },
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
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      (_inWatchList)
                                          ? WatchlistService()
                                              .removeFromWatchList(
                                              tv.id.toString(),
                                              userId,
                                            )
                                          : WatchlistService().addToWatchlist(
                                              userId,
                                              "tv",
                                              tv.id.toString(),
                                            );
                                      _inWatchList = !_inWatchList;
                                    });
                                  },
                                  iconSize: 36,
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    child: _inWatchList
                                        ? const Icon(Icons.bookmark,
                                            key: ValueKey(true),
                                            color: Color.fromARGB(
                                                255, 243, 190, 31))
                                        : const Icon(
                                            Icons.bookmark_border_rounded,
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
                          FutureBuilder<List<String>>(
                            future: _imagesFuture,
                            builder: (context, snapshot) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Story :",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    tv.overview,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "First Aired Date :",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  Text(
                                    tv.firstAirDate,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Original Language :",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  Text(
                                    tv.originalLanguage,
                                  ),
                                  const SizedBox(height: 20),
                                  Divider(
                                    color: Colors.grey[700],
                                  ),
                                  Text(
                                    "Season :",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio:
                                          0.65, // keeps poster shape nice
                                    ),
                                    itemCount: tv.seasons.length,
                                    itemBuilder: (context, index) {
                                      final season = tv.seasons[index];
                                      final posterUrl =
                                          "https://image.tmdb.org/t/p/w500${season.posterPath}";

                                      return GestureDetector(
                                        onTap: () => _navigateToSeasonDetail(
                                            season, season.seasonNumber),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(22),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          color: CineMindTheme.cardDark,
                                          elevation: 10,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              // Poster
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(22),
                                                  child: Image.network(
                                                    posterUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            Container(
                                                      color: Colors.grey[800],
                                                      child: const Center(
                                                        child: Icon(
                                                            Icons.broken_image,
                                                            color:
                                                                Colors.white54,
                                                            size: 50),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Season number
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Season ${season.seasonNumber}",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
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
