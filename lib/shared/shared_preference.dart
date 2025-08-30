import 'package:shared_preferences/shared_preferences.dart';

class CustomeShared {
  static const String loadFavoriteMovieKey = 'favorite_movie';

  Future<SharedPreferences> _prefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<List<int>> getFavoriteMovies() async {
    final prefs = await _prefs();
    List<String>? stringList = prefs.getStringList(loadFavoriteMovieKey);
    return stringList?.map(int.parse).toList() ?? [];
  }

  Future<bool> isMovieFavorite(int movieId) async {
    List<int> favorites = await getFavoriteMovies();
    return favorites.contains(movieId);
  }

  Future<void> toggleFavoriteMovie(int movieId) async {
    final prefs = await _prefs();
    List<int> favorites = await getFavoriteMovies();
    if (favorites.contains(movieId)) {
      favorites.remove(movieId);
    } else {
      favorites.add(movieId);
    }
    await prefs.setStringList(
        loadFavoriteMovieKey, favorites.map((e) => e.toString()).toList());
  }

// favorite tv serie
  static const String loadFavoriteTvKey = 'favorite_tv';
  Future<bool> isTvSerieFavorite(int tvSerieId) async {
    List<int> favorites = await getFavoriteTvSerie();
    return favorites.contains(tvSerieId);
  }

  Future<List<int>> getFavoriteTvSerie() async {
    final prefs = await _prefs();
    List<String>? stringList = prefs.getStringList(loadFavoriteTvKey);
    return stringList?.map(int.parse).toList() ?? [];
  }

  Future<void> toggleFavoriteTv(int tvSerieId) async {
    final prefs = await _prefs();
    List<int> favorites = await getFavoriteTvSerie();
    if (favorites.contains(tvSerieId)) {
      favorites.remove(tvSerieId);
    } else {
      favorites.add(tvSerieId);
    }
    await prefs.setStringList(
        loadFavoriteTvKey, favorites.map((e) => e.toString()).toList());
  }
}
