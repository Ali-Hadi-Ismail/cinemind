import 'package:shared_preferences/shared_preferences.dart';

class CustomeShared {
  static const String loadFavoriteMovieKey = 'favorite_movie';

  Future<SharedPreferences> _prefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<List<int>> getLovedMovies() async {
    final prefs = await _prefs();
    List<String>? stringList = prefs.getStringList(loadFavoriteMovieKey);
    return stringList?.map(int.parse).toList() ?? [];
  }

  Future<bool> isLoved(int movieId) async {
    List<int> loved = await getLovedMovies();
    return loved.contains(movieId);
  }

  Future<void> toggleLove(int movieId) async {
    final prefs = await _prefs();
    List<int> loved = await getLovedMovies();
    if (loved.contains(movieId)) {
      loved.remove(movieId);
    } else {
      loved.add(movieId);
    }
    await prefs.setStringList(
        loadFavoriteMovieKey, loved.map((e) => e.toString()).toList());
  }
}
