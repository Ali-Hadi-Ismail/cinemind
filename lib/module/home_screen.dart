import 'package:cinemind/shared/cubit/movie/movie_cubit.dart';
import 'package:cinemind/shared/cubit/movie/movie_state.dart';
import 'package:cinemind/shared/repo/movie_repo.dart';
import 'package:cinemind/shared/repo/tv_repo.dart';
import 'package:cinemind/shared/service/tv_serie_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../shared/cubit/tv/tv_top_rated/tv_popular_cubit.dart';
import '../shared/cubit/tv/tv_top_rated/tv_popular_state.dart';
import '../shared/widget/movie_card_horiz.dart';
import '../shared/widget/tv_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;
  final List<String> categories = ['All', 'Comedy', 'Animation', 'Documentary'];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              MovieCubit(MovieRepository())..fetchCategory('popular'),
        ),
        BlocProvider(
          create: (_) => TvPopularCubit(
            repo: TvRepo(
              service: TvSerieService(),
              cacheBox: Hive.box('tv_cache'),
            ),
          )..fetchPopularList(),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildFeatured(),
                const SizedBox(height: 30),
                _buildCategories(),
                const SizedBox(height: 25),
                _buildMostPopularMovies(),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // Header
  // -------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.5),
              image: const DecorationImage(
                image: AssetImage('assets/profile.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, Smith',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  "Let's stream your favorite movie",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // Featured Movie (static for now)
  // -------------------------------

  // -------------------------------
  // Categories
  // -------------------------------
  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Categories',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 35,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final isSelected = selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () => setState(() => selectedCategoryIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00D4FF)
                        : const Color(0xFF2A2A3E),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // -------------------------------
  // Most Popular Movies
  // -------------------------------
  Widget _buildMostPopularMovies() {
    return Column(
      children: [
        _sectionHeader("Most Popular Movies"),
        SizedBox(
          height: 180,
          child: BlocBuilder<MovieCubit, MovieState>(
            builder: (context, state) {
              if (state is MovieLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MovieLoaded) {
                final movies = state.popular;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: movies.length,
                  itemBuilder: (_, i) => MovieCard(movie: movies[i]),
                );
              } else if (state is MovieError) {
                return Center(
                    child: Text(state.message,
                        style: const TextStyle(color: Colors.white)));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  // -------------------------------
  // Most Popular TV
  // -------------------------------
  Widget _buildFeatured() {
    return BlocBuilder<TvPopularCubit, TvPopularState>(
      builder: (context, state) {
        if (state is TvPopularLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TvPopularLoaded) {
          if (state.popularList.isEmpty) return const SizedBox.shrink();
          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.popularList.length,
              itemBuilder: (context, index) {
                final tv = state.popularList[index];
                return TvCard(tv: tv);
              },
            ),
          );
        } else if (state is TvPopularError) {
          return Center(
              child: Text(
            state.message,
            style: const TextStyle(color: Colors.white),
          ));
        }
        return const SizedBox.shrink();
      },
    );
  }

  // -------------------------------
  // Small reusable section header
  // -------------------------------
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const Text("See All",
              style: TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
