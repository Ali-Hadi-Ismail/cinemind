// search_screen.dart — FIXED & CLEANED
import 'dart:async';
import 'package:cinemind/shared/cubit/search/movie/search_movie_cubit.dart';
import 'package:cinemind/shared/cubit/search/movie/search_movie_state.dart';
import 'package:cinemind/shared/cubit/search/tv/search_tv_serie_cubit.dart';
import 'package:cinemind/shared/cubit/search/tv/search_tv_serie_state.dart';
import 'package:cinemind/shared/service/movie_service.dart';
import 'package:cinemind/shared/service/search_service.dart';
import 'package:cinemind/shared/repo/search_repo.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:cinemind/shared/widget/card/movie_card.dart';
import 'package:cinemind/shared/widget/card/tv_card_poster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

import '../../shared/service/tv_serie_service.dart';
import '../detail/movie_detail_screen.dart';
import '../detail/tv_serie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;
  bool _isLoadingMore = false;

  // filters
  bool _includeAdult = false;
  bool _isMovie = true;

  // cubits
  late final SearchMovieCubit _searchMovieCubit;
  late final SearchTvCubit _searchTvCubit;

  @override
  void initState() {
    super.initState();

    final repo = SearchRepo(SearchService());
    _searchMovieCubit = SearchMovieCubit(repo);
    _searchTvCubit = SearchTvCubit(repo);

    _setupSearchListener();
    _setupScrollListener();
  }

  void _setupSearchListener() {
    _controller.addListener(() {
      final query = _controller.text;
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () {
        _performSearch(query);
      });
      setState(() {});
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final pos = _scrollController.position;
      final threshold = pos.maxScrollExtent - 200;

      final activeHasReachedMax = _isMovie
          ? _searchMovieCubit.hasReachedMax
          : _searchTvCubit.hasReachedMax;

      if (pos.pixels >= threshold &&
          !_isLoadingMore &&
          !activeHasReachedMax &&
          _controller.text.trim().isNotEmpty) {
        _loadMoreResults();
      }
    });
  }

  void _performSearch(String query) {
    final year = _yearController.text.isNotEmpty
        ? int.tryParse(_yearController.text)
        : null;

    if (_isMovie) {
      _searchMovieCubit.search(query, year: year, includeAdult: _includeAdult);
    } else {
      _searchTvCubit.search(query,
          firstAirDateYear: year, includeAdult: _includeAdult);
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    final year = _yearController.text.isNotEmpty
        ? int.tryParse(_yearController.text)
        : null;

    if (_isMovie) {
      await _searchMovieCubit.loadNextPage(
          year: year, includeAdult: _includeAdult);
    } else {
      await _searchTvCubit.loadNextPage(includeAdult: _includeAdult);
    }

    if (mounted) setState(() => _isLoadingMore = false);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        bool dialogIsMovie = _isMovie;
        bool dialogIncludeAdult = _includeAdult;
        final TextEditingController dialogYearController =
            TextEditingController(text: _yearController.text);

        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: const Color(0xFF2a2a2d),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.red.withOpacity(0.3), width: 1),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Colors.white24, width: 0.5))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Search Filters',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAdultToggle(setDialogState, dialogIncludeAdult,
                              (val) => dialogIncludeAdult = val),
                          const SizedBox(height: 16),
                          _buildMediaTypeSwitch(setDialogState, dialogIsMovie,
                              (val) => dialogIsMovie = val),
                          const SizedBox(height: 16),
                          _buildYearField(setDialogState, dialogYearController),
                          const SizedBox(height: 16),
                          _buildDialogActionButtons(
                            context,
                            setDialogState,
                            dialogIncludeAdult,
                            dialogIsMovie,
                            dialogYearController,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildAdultToggle(
      StateSetter setDialogState, bool includeAdult, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.verified_user, color: CineMindTheme.primaryRed),
          const SizedBox(width: 12),
          const Text('Content Rating',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ChoiceChip(
            label: const Text('Family'),
            selected: !includeAdult,
            onSelected: (_) => setDialogState(() => onChanged(false)),
            selectedColor: Colors.green[800],
            labelStyle: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 12),
          ChoiceChip(
            label: const Text('Adult'),
            selected: includeAdult,
            onSelected: (_) => setDialogState(() => onChanged(true)),
            selectedColor: Colors.red[800],
            labelStyle: const TextStyle(color: Colors.white),
          ),
        ]),
      ]),
    );
  }

  Widget _buildMediaTypeSwitch(
      StateSetter setDialogState, bool isMovie, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.movie_filter, color: CineMindTheme.primaryRed),
          const SizedBox(width: 12),
          const Text('Media Type',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 12),
        Center(
          child: LiteRollingSwitch(
            onTap: () {},
            onDoubleTap: () {},
            onSwipe: () {},
            value: isMovie,
            textOn: 'Movie',
            textOff: 'TV Series',
            colorOn: const Color.fromARGB(255, 241, 2, 2),
            colorOff: const Color.fromARGB(255, 36, 68, 232),
            textOnColor: Colors.white,
            onChanged: (state) => setDialogState(() => onChanged(state)),
          ),
        ),
      ]),
    );
  }

  Widget _buildYearField(
      StateSetter setDialogState, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.calendar_today, color: CineMindTheme.primaryRed),
          const SizedBox(width: 12),
          const Text('Release Year',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 12),
        TextFormField(
          focusNode: _focusNode,
          readOnly: true,
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g., ${DateTime.now().year}',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF47474a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onTap: () => _showYearPicker(setDialogState, controller),
        ),
      ]),
    );
  }

  void _showYearPicker(
      StateSetter setDialogState, TextEditingController controller) {
    final currentYear = DateTime.now().year;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF2a2a2d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.red.withOpacity(0.3), width: 1),
          ),
          child: Container(
            height: 400,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('Select Year',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentYear - 1900 + 6,
                    reverse: true,
                    itemBuilder: (c, i) {
                      final year = currentYear + 5 - i;
                      final isSelected = controller.text == year.toString();
                      return ListTile(
                        title: Text(year.toString(),
                            style: TextStyle(
                                color: isSelected
                                    ? CineMindTheme.primaryRed
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        tileColor: isSelected
                            ? CineMindTheme.primaryRed.withOpacity(0.1)
                            : null,
                        onTap: () {
                          controller.text = year.toString();
                          setDialogState(() {});
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogActionButtons(
    BuildContext context,
    StateSetter setDialogState,
    bool dialogIncludeAdult,
    bool dialogIsMovie,
    TextEditingController dialogYearController,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setDialogState(() {
                dialogIncludeAdult = false;
                dialogYearController.clear();
                dialogIsMovie = true;
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white70),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Reset',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _includeAdult = dialogIncludeAdult;
                _isMovie = dialogIsMovie;
                _yearController.text = dialogYearController.text;
              });
              Navigator.pop(context);
              _performSearch(_controller.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CineMindTheme.primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _yearController.dispose();
    _scrollController.dispose();
    _searchMovieCubit.close();
    _searchTvCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchMovieCubit>.value(value: _searchMovieCubit),
        BlocProvider<SearchTvCubit>.value(value: _searchTvCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Search Media",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _buildSearchTextField()),
                  const SizedBox(width: 8),
                  IconButton(
                      onPressed: _showFilterDialog,
                      icon:
                          const Icon(Icons.filter_list, color: Colors.white70),
                      tooltip: 'Search Filters'),
                ]),
                const SizedBox(height: 20),
                Expanded(child: _buildResults()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTextField() {
    return TextFormField(
      controller: _controller,
      style: const TextStyle(color: Colors.white),
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF47474a),
        contentPadding: const EdgeInsets.all(10),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
                color: Colors.red, width: 1.5, strokeAlign: 0.3)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
                color: Colors.red, width: 1.5, strokeAlign: 0.3)),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                color: Colors.white70,
                onPressed: () {
                  _controller.clear();
                  _searchMovieCubit.search("");
                  FocusScope.of(context).unfocus();
                  _searchTvCubit.search("");
                  setState(() {});
                })
            : null,
        hintText: "Type movie name, title, etc",
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
      ),
      onFieldSubmitted: (value) => _performSearch(value),
    );
  }

  Widget _buildResults() {
    if (_isMovie) {
      return BlocBuilder<SearchMovieCubit, SearchMovieState>(
        builder: (context, state) {
          if (state is SearchMovieInitial) {
            return const Center(
                child: Text("Start typing...",
                    style: TextStyle(color: Colors.white70)));
          }
          if (state is SearchMovieLoading) {
            return const Center(
                child: SpinKitHourGlass(color: CineMindTheme.primaryRed));
          }
          if (state is SearchMovieError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red)));
          }
          if (state is SearchMovieEmpty) {
            return const Center(
                child: Text("No results found",
                    style: TextStyle(color: Colors.white70)));
          }
          if (state is SearchMovieLoaded) {
            final results = state.results;
            return ListView.builder(
              controller: _scrollController,
              itemCount: results.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == results.length) {
                  return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: SpinKitCircle(color: Colors.red)));
                }
                final movie = results[index];
                return GestureDetector(
                  onTap: () async {
                    _focusNode.unfocus();
                    showDialog(
                        context: context,
                        builder: (_) => const Center(
                            child: SpinKitSpinningLines(
                                color: CineMindTheme.primaryRed)),
                        barrierDismissible: false);
                    try {
                      final movieDetail =
                          await MovieService().fetchMovieById(movie.id);
                      Navigator.pop(context);
                      if (movieDetail != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    MovieDetailsScreen(movie: movieDetail)));
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to load movie: $e')));
                    }
                  },
                  child: MovieCard(movie: movie),
                );
              },
            );
          }
          return const SizedBox();
        },
      );
    } else {
      return BlocBuilder<SearchTvCubit, SearchTvState>(
        builder: (context, state) {
          if (state is SearchTvInitial) {
            return const Center(
                child: Text("Start typing...",
                    style: TextStyle(color: Colors.white70)));
          }
          if (state is SearchTvLoading) {
            return const Center(
                child: SpinKitHourGlass(color: CineMindTheme.primaryRed));
          }
          if (state is SearchTvError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red)));
          }
          if (state is SearchTvEmpty) {
            return const Center(
                child: Text("No results found",
                    style: TextStyle(color: Colors.white70)));
          }
          if (state is SearchTvLoaded) {
            final results = state.results;
            return ListView.builder(
              controller: _scrollController,
              itemCount: results.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == results.length) {
                  return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: SpinKitCircle(color: Colors.red)));
                }
                final tv = results[index];
                return GestureDetector(
                  onTap: () async {
                    _focusNode.unfocus();
                    final tvDetailItem =
                        await TvSerieService().fetchTvSerieByID(tv.id);
                    if (tvDetailItem != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TvDetailsScreen(tvSerie: tvDetailItem)));
                    }
                  },
                  child: TvSerieCard(tvSerie: tv),
                );
              },
            );
          }
          return const SizedBox();
        },
      );
    }
  }
}
