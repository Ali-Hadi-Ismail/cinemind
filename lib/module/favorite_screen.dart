import 'package:cinemind/model/movie.dart';
import 'package:cinemind/shared/service/movie_service.dart';
import 'package:cinemind/shared/shared_preference.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:cinemind/shared/widget/card/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Movie> favoriteMovies = []; // This is a normal list
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites(); // Load async in background
  }

  Future<void> loadFavorites() async {
    List<int> moviesIdList = await CustomeShared().getLovedMovies();
    List<Movie> movies = [];

    for (int id in moviesIdList) {
      Movie? movie = await MovieService().fetchMovieById(id);
      if (movie != null) movies.add(movie);
    }

    setState(() {
      favoriteMovies = movies; // assign to normal list
      isLoading = false; // stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Favorite",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: (isLoading)
          ? Container(
              width: double.infinity,
              height: double.infinity,
              child: SpinKitHourGlass(color: CineMindTheme.primaryRed),
            )
          : ListView.builder(
              itemCount: favoriteMovies.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: favoriteMovies[index]);
              },
            ),
    );
  }
}
