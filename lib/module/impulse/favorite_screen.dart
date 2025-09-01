import 'package:cinemind/model/movie.dart';
import 'package:cinemind/module/detail/movie_detail_screen.dart';
import 'package:cinemind/module/detail/tv_serie_detail_screen.dart';
import 'package:cinemind/shared/service/favorite_service.dart';
import 'package:cinemind/shared/service/movie_service.dart';
import 'package:cinemind/shared/service/tv_serie_service.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:cinemind/shared/widget/card/movie_card.dart';
import 'package:cinemind/shared/widget/card/tv_card_poster.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../model/tv_series.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Movie> favoriteMovies = [];
  List<TvSerie> favoriteTv = [];
  bool isLoading = true;
  bool showMovies = true; // true = Movies, false = TV Series
  final userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    loadFavorites(); // Default: load movies
  }

  Future<void> loadFavorites() async {
    setState(() => isLoading = true);

    if (showMovies) {
      // Load favorite movies
      List<String> moviesIdListString =
          await FavoriteService().getAllFavoriteMovie(userId);
      List<int> moviesIdList =
          moviesIdListString.map((e) => int.parse(e)).toList();
      List<Movie> movies = [];
      for (int id in moviesIdList) {
        Movie? movie = await MovieService().fetchMovieById(id);
        if (movie != null) movies.add(movie);
      }
      if (!mounted) return;
      setState(() {
        favoriteMovies = movies;
        isLoading = false;
      });
    } else {
      // Load favorite movies
      List<String> tvIdListString =
          await FavoriteService().getAllFavoriteTv(userId);
      List<int> tvIdList = tvIdListString.map((e) => int.parse(e)).toList();
      List<TvSerie> tvSeries = [];
      for (int id in tvIdList) {
        TvSerie? tv = await TvSerieService().fetchTvSerieByID(id);
        if (tv != null) tvSeries.add(tv);
      }
      if (!mounted) return;
      setState(() {
        favoriteTv = tvSeries;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final emptyMessage = Center(
      child: Text(
        "There is no masterpiece you like!",
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Favorites",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: SpinKitHourGlass(
                color: showMovies ? CineMindTheme.primaryRed : Colors.blue,
                size: 50.0,
              ),
            )
          : Column(
              children: [
                ToggleSwitch(
                  minWidth: 70.0,
                  initialLabelIndex: showMovies ? 0 : 1,
                  cornerRadius: 20.0,
                  activeBgColors: [
                    [CineMindTheme.primaryRed], // Movies -> Red
                    [Colors.blue], // TV -> Blue
                  ],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey.shade300,
                  inactiveFgColor: Colors.black,
                  icons: [Icons.movie, Icons.tv],
                  onToggle: (index) {
                    setState(() {
                      showMovies = index == 0;
                    });
                    loadFavorites(); // reload based on toggle
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: Builder(
                      builder: (context) {
                        final isEmpty = showMovies
                            ? favoriteMovies.isEmpty
                            : favoriteTv.isEmpty;

                        if (isEmpty) {
                          return emptyMessage;
                        }

                        return ListView.builder(
                          itemCount: showMovies
                              ? favoriteMovies.length
                              : favoriteTv.length,
                          itemBuilder: (context, index) {
                            if (showMovies) {
                              final movie = favoriteMovies[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MovieDetailsScreen(movie: movie),
                                    ),
                                  );
                                },
                                child: MovieCard(movie: movie),
                              );
                            } else {
                              final tv = favoriteTv[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TvDetailsScreen(tvSerie: tv),
                                    ),
                                  );
                                },
                                child: TvSerieCard(tvSerie: tv),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
