import 'episode.dart';

class Season {
  final int id;
  final String airDate;
  final String name;
  final String overview;
  final int seasonNumber;
  final double voteAverage;
  final String? posterPath;
  final List<Episode> episodes;

  Season({
    required this.id,
    required this.airDate,
    required this.name,
    required this.overview,
    required this.seasonNumber,
    required this.voteAverage,
    this.posterPath,
    required this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? 0,
      airDate: json['air_date'] ?? '',
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      seasonNumber: json['season_number'] ?? 0,
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      posterPath: json['poster_path'],
      episodes: json['episodes'] != null
          ? List<Episode>.from(json['episodes'].map((x) => Episode.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'air_date': airDate,
      'name': name,
      'overview': overview,
      'season_number': seasonNumber,
      'vote_average': voteAverage,
      'poster_path': posterPath,
      'episodes': episodes.map((x) => x.toJson()).toList(),
    };
  }
}
