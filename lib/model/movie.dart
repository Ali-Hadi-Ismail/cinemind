import 'collection.dart';
import 'gener.dart';
import 'production_company.dart';

class Movie {
  final int id;
  final String title;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final String releaseDate;
  final int runtime;
  final bool adult;
  final int budget;
  final int revenue;
  final String posterPath;
  final String backdropPath;
  final String tagline;
  final String homepage;
  final bool hasVideo;

  final List<ProductionCompany> productionCompanies;
  final List<Genre> genres;

  Movie({
    required this.id,
    required this.title,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.releaseDate,
    required this.runtime,
    required this.adult,
    required this.budget,
    required this.revenue,
    required this.posterPath,
    required this.backdropPath,
    required this.tagline,
    required this.homepage,
    required this.hasVideo,
    required this.productionCompanies,
    required this.genres,
  });

  // From JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String,
      originalLanguage: json['original_language'] as String,
      originalTitle: json['original_title'] as String,
      overview: json['overview'] as String,
      releaseDate: json['release_date'] as String,
      runtime: json['runtime'] ?? 0,
      adult: json['adult'] as bool,
      budget: json['budget'] ?? 0,
      revenue: json['revenue'] ?? 0,
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      tagline: json['tagline'] ?? '',
      homepage: json['homepage'] ?? '',
      hasVideo: json['video'] as bool,
      productionCompanies: (json['production_companies'] as List<dynamic>?)
              ?.map((e) => ProductionCompany.fromJson(e))
              .toList() ??
          [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e))
              .toList() ??
          [],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'original_language': originalLanguage,
      'original_title': originalTitle,
      'overview': overview,
      'release_date': releaseDate,
      'runtime': runtime,
      'adult': adult,
      'budget': budget,
      'revenue': revenue,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'tagline': tagline,
      'homepage': homepage,
      'video': hasVideo,
      'production_companies':
          productionCompanies.map((e) => e.toJson()).toList(),
      'genres': genres.map((e) => e.toJson()).toList(),
    };
  }
}
