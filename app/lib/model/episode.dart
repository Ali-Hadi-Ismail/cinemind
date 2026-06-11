import 'crew.dart';
import 'guest_start.dart';

class Episode {
  final int id;
  final int seriesId;
  final int seasonNumber;
  final int episodeNumber;
  final String name;
  final String overview;
  final String airDate;
  final int runtime;
  final String productionCode;
  final String? stillPath;
  final double voteAverage;
  final int voteCount;
  final List<Crew> crew;
  final List<GuestStar> guestStars;

  Episode({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.name,
    required this.overview,
    required this.airDate,
    required this.runtime,
    required this.productionCode,
    this.stillPath,
    required this.voteAverage,
    required this.voteCount,
    required this.crew,
    required this.guestStars,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? 0,
      seriesId: json['series_id'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      episodeNumber: json['episode_number'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      airDate: json['air_date'] ?? '',
      runtime: json['runtime'] ?? 0,
      productionCode: json['production_code'] ?? '',
      stillPath: json['still_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      crew: json['crew'] != null
          ? List<Crew>.from(json['crew'].map((x) => Crew.fromJson(x)))
          : [],
      guestStars: json['guest_stars'] != null
          ? List<GuestStar>.from(
              json['guest_stars'].map((x) => GuestStar.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'series_id': seriesId,
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      'name': name,
      'overview': overview,
      'air_date': airDate,
      'runtime': runtime,
      'production_code': productionCode,
      'still_path': stillPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'crew': crew.map((x) => x.toJson()).toList(),
      'guest_stars': guestStars.map((x) => x.toJson()).toList(),
    };
  }
}
