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

  final Collection? belongsToCollection;
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
    this.belongsToCollection,
    required this.productionCompanies,
    required this.genres,
  });
}
