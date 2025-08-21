import 'season.dart';
import 'production_company.dart';

class TvSeries {
  final bool adult;
  final String? backdropPath;
  final int id;
  final String firstAirDate;
  final bool inProduction;
  final String? lastAirDate;
  final String name;
  final String? nextEpisodeToAir;
  final String? lastEpisodeToAir;
  final int numberOfEpisodes;
  final String originalLanguage;
  final String overview;
  final String? posterPath;
  final List<ProductionCompany> productionCompanies;
  final List<Season> seasons;

  TvSeries({
    required this.adult,
    this.backdropPath,
    required this.id,
    required this.firstAirDate,
    required this.inProduction,
    this.lastAirDate,
    required this.name,
    this.nextEpisodeToAir,
    this.lastEpisodeToAir,
    required this.numberOfEpisodes,
    required this.originalLanguage,
    required this.overview,
    this.posterPath,
    required this.productionCompanies,
    required this.seasons,
  });

  factory TvSeries.fromJson(Map<String, dynamic> json) => TvSeries(
        adult: json['adult'] ?? false,
        backdropPath: json['backdrop_path'],
        id: json['id'],
        firstAirDate: json['first_air_date'] ?? '',
        inProduction: json['in_production'] ?? false,
        lastAirDate: json['last_air_date'],
        name: json['name'] ?? '',
        nextEpisodeToAir: json['next_episode_to_air'],
        lastEpisodeToAir: json['last_episode_to_air'] != null
            ? json['last_episode_to_air']['air_date']
            : null,
        numberOfEpisodes: json['number_of_episodes'] ?? 0,
        originalLanguage: json['original_language'] ?? '',
        overview: json['overview'] ?? '',
        posterPath: json['poster_path'],
        productionCompanies: json['production_companies'] != null
            ? List<ProductionCompany>.from(json['production_companies']
                .map((x) => ProductionCompany.fromJson(x)))
            : [],
        seasons: json['seasons'] != null
            ? List<Season>.from(json['seasons'].map((x) => Season.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'adult': adult,
        'backdrop_path': backdropPath,
        'id': id,
        'first_air_date': firstAirDate,
        'in_production': inProduction,
        'last_air_date': lastAirDate,
        'name': name,
        'next_episode_to_air': nextEpisodeToAir,
        'last_episode_to_air': lastEpisodeToAir,
        'number_of_episodes': numberOfEpisodes,
        'original_language': originalLanguage,
        'overview': overview,
        'poster_path': posterPath,
        'production_companies':
            productionCompanies.map((x) => x.toJson()).toList(),
        'seasons': seasons.map((x) => x.toJson()).toList(),
      };
}
