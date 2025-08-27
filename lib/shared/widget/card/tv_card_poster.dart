import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../model/tv_series.dart';
import '../../theme/theme.dart';
import '../../utils/image_helper.dart';

class TvSerieCard extends StatelessWidget {
  final TvSerie tvSerie;

  const TvSerieCard({super.key, required this.tvSerie});

  @override
  Widget build(BuildContext context) {
    final posterPath = tvSerie.posterPath ?? '';
    final posterUrl =
        posterPath.isNotEmpty ? ImageHelper.poster(posterPath) : null;

    final titleStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    final metaStyle = const TextStyle(fontSize: 14, color: Colors.grey);
    final overviewStyle = const TextStyle(fontSize: 13, color: Colors.white70);

    return Container(
      height: 150, // <-- important: fixed height bounds the Row/Expanded
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: CineMindTheme.cardDark.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: posterUrl != null
                ? Image.network(posterUrl,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                    loadingBuilder: (c, child, p) {
                      if (p == null) return child;
                      return Container(
                        width: 100,
                        height: 150,
                        color: CineMindTheme.cardDark.withOpacity(0.3),
                        child: Center(
                            child: SpinKitHourGlass(
                                color: CineMindTheme.primaryRed)),
                      );
                    },
                    errorBuilder: (_, __, ___) => _placeholderBox())
                : _placeholderBox(),
          ),
          const SizedBox(width: 16),
          // The content area is constrained by the Container height (150)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tvSerie.name.isNotEmpty ? tvSerie.name : 'Unknown Title',
                      style: titleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 20),
                  Row(children: [
                    const Icon(Icons.date_range, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            _formatAirDates(
                                tvSerie.firstAirDate, tvSerie.lastAirDate),
                            style: metaStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 20),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.language, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("${tvSerie.originalLanguage}", style: metaStyle),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderBox() => Container(
        width: 100,
        height: 150,
        color: Colors.grey[800],
        child: const Center(
            child: Icon(Icons.tv, size: 40, color: Colors.white54)),
      );

  String _formatAirDates(String first, String? last) {
    if ((first.isEmpty || first == 'null') && (last == null || last.isEmpty))
      return 'Unknown';
    if (first.isEmpty || first == 'null') return last ?? 'Unknown';
    if (last == null || last.isEmpty || last == 'null') return first;
    return '$first → $last';
  }
}
