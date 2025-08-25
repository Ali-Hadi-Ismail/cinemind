import 'dart:async';
import 'package:cinemind/shared/cubit/movie/movie_cubit.dart';
import 'package:cinemind/shared/cubit/movie/movie_state.dart';
import 'package:cinemind/shared/repo/movie_repo.dart';
import 'package:cinemind/shared/repo/tv_repo.dart';
import 'package:cinemind/shared/service/tv_serie_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:palette_generator/palette_generator.dart';

import '../shared/cubit/tv/tv_trending/tv_trending_cubit.dart';
import '../shared/cubit/tv/tv_trending/tv_trending_state.dart';
import '../shared/widget/card/auto_scrolling_card.dart';
import '../shared/widget/card/movie_card_horiz.dart';

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
          create: (_) => MovieCubit(MovieRepository())..fetchAllMovies(),
        ),
        BlocProvider(
          create: (_) => TvTrendingCubit(
            repo: TvRepo(
              service: TvSerieService(),
              cacheBox: Hive.box('tv_cache'),
            ),
          )..fetchTrendingList(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomeAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                _buildTrendingTvSerie(),
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

  AppBar CustomeAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      toolbarHeight: 80, // smaller than default
      centerTitle: false,
      leading: GestureDetector(
        onTap: () {
          // TODO: Navigate to profile / login
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade800,
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Hello, Ali",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "\"Good morning, Vietnam!\"",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Navigate to wishlist
          },
          icon: const Icon(Icons.favorite),
          color: Colors.red,
          iconSize: 28,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildTrendingTvSerie() {
    return Column(
      children: [
        _sectionHeader("Treding TV Shows"),
        const SizedBox(height: 10),
        BlocBuilder<TvTrendingCubit, TvTrendingState>(
          builder: (context, state) {
            if (state is TvTrendingLoading) {
              return const SizedBox(
                height: 280,
                child: Center(
                    child: CircularProgressIndicator(
                  color: Color(0xFF00D4FF),
                )),
              );
            } else if (state is TvTrendingLoaded) {
              if (state.trendingList.isEmpty) return const SizedBox.shrink();
              return AutoScrollingTvCards(tvShows: state.trendingList);
            } else if (state is TvTrendingError) {
              return SizedBox(
                height: 280,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.grey.shade400,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load TV shows',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
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

  Widget _buildMostPopularMovies() {
    return Column(
      children: [
        _sectionHeader("Most Popular Movies"),
        SizedBox(
          height: 180,
          child: BlocBuilder<MovieCubit, MovieState>(
            builder: (context, state) {
              if (state is MovieLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Color(0xFF00D4FF),
                ));
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.grey.shade400,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load movies',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

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
          GestureDetector(
            onTap: () {
              // Add navigation to see all screen
            },
            child: const Text("See All",
                style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
