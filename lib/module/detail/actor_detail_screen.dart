import 'package:cinemind/shared/service/movie_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../model/cast.dart';
import '../../shared/widget/image_full_screen.dart';

class CastDetailsScreen extends StatefulWidget {
  final int castId;

  const CastDetailsScreen({
    super.key,
    required this.castId,
  });

  @override
  State<CastDetailsScreen> createState() => _CastDetailsScreenState();
}

class _CastDetailsScreenState extends State<CastDetailsScreen> {
  Cast? detailedCast;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCastDetails();
  }

  void _loadCastDetails() async {
    try {
      Cast? details = await MovieService().getPersonDetailById(widget.castId);
      setState(() {
        detailedCast = details;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading cast details: $e');
    }
  }

  String _normalizeImageUrl(String? path,
      {bool backdrop = false, bool cast = false}) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;

    if (cast) {
      return 'https://image.tmdb.org/t/p/w500$path';
    }

    return backdrop
        ? 'https://image.tmdb.org/t/p/w780$path'
        : 'https://image.tmdb.org/t/p/w342$path';
  }

  String _getGender(Cast cast) {
    switch (cast.gender) {
      case 1:
        return 'Female';
      case 2:
        return 'Male';
      default:
        return 'Not specified';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || detailedCast == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: const Center(
          child: SpinKitHourGlass(
            color: Colors.red,
            size: 50.0,
          ),
        ),
      );
    }

    final cast = detailedCast!;
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
                        _normalizeImageUrl(cast.profilePath, cast: true)
                                .isNotEmpty
                            ? _normalizeImageUrl(cast.profilePath, cast: true)
                            : 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=500&h=600&fit=crop',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(color: Colors.grey[850]);
                        },
                        errorBuilder: (context, error, stack) {
                          return Container(
                            color: Colors.grey[850],
                            child: const Center(
                              child: Icon(Icons.person,
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
                                if (_normalizeImageUrl(cast.profilePath,
                                        cast: true)
                                    .isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullscreenImagePage(
                                        imageUrl: _normalizeImageUrl(
                                            cast.profilePath,
                                            cast: true),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _normalizeImageUrl(cast.profilePath,
                                              cast: true)
                                          .isNotEmpty
                                      ? _normalizeImageUrl(cast.profilePath,
                                          cast: true)
                                      : 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=300&h=450&fit=crop',
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(color: Colors.grey[800]);
                                  },
                                  errorBuilder: (context, error, stack) {
                                    return Container(
                                      color: Colors.grey[800],
                                      child: const Center(
                                        child: Icon(Icons.person,
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
                                  cast.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                if (cast.character.isNotEmpty)
                                  Text(
                                    'as ${cast.character}',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _buildInfoChip(cast.knownForDepartment),
                                    _buildInfoChip(_getGender(cast)),
                                  ],
                                ),
                              ],
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biography',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cast.biography,
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
                    _buildDetailRow(
                        'Real Name',
                        cast.originalName.isNotEmpty
                            ? cast.originalName
                            : cast.name),
                    _buildDetailRow('Known For', cast.knownForDepartment),
                    _buildDetailRow('Gender', _getGender(cast)),
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
}
