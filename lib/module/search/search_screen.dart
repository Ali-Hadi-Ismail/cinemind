import 'dart:async';
import 'package:cinemind/shared/cubit/search/search_cubit.dart';
import 'package:cinemind/shared/cubit/search/search_state.dart';
import 'package:cinemind/shared/widget/card/movie_card.dart';
import 'package:cinemind/shared/repo/search_repo.dart';
import 'package:cinemind/shared/service/search_service.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../detail/movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  late final SearchCubit _searchCubit;
  final ScrollController _scrollController = ScrollController();
  String _lastQuery = "";
  bool _isLoadingNext = false;
  bool _showLoadMoreButton = false;

  void _tryLoadNextPage() async {
    if (_isLoadingNext) return;

    final query = _lastQuery.trim();
    if (query.isEmpty) return;

    final nextPage = _searchCubit.currentPage + 1;
    setState(() => _isLoadingNext = true);

    try {
      await _searchCubit.search(query, page: nextPage);
    } finally {
      if (mounted) setState(() => _isLoadingNext = false);
    }
  }

  void _onPageSelected(int page) {
    if (page == _searchCubit.currentPage) return;
    _jumpToPage(page, scrollToTop: false);
  }

  Future<void> _jumpToPage(int page, {bool scrollToTop = true}) async {
    final query = _lastQuery.trim();
    if (query.isEmpty) return;

    setState(() => _isLoadingNext = true);
    await _searchCubit.search(query, page: page);
    if (!mounted) return;

    if (scrollToTop) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    setState(() => _isLoadingNext = false);
  }

  @override
  void initState() {
    super.initState();

    _searchCubit = SearchCubit(SearchRepo(SearchService()));

    _controller.addListener(() {
      final query = _controller.text;

      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () {
        _lastQuery = query;
        _searchCubit.search(query);
      });
    });

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position;
      final atBottom = pos.pixels >= (pos.maxScrollExtent - 20);
      if (atBottom && !_showLoadMoreButton && _lastQuery.isNotEmpty) {
        setState(() => _showLoadMoreButton = true);
      } else if (!atBottom && _showLoadMoreButton) {
        setState(() => _showLoadMoreButton = false);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _searchCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchCubit,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: _controller,
                  style: const TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF47474a),
                      contentPadding: EdgeInsets.all(10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.5,
                          strokeAlign: 0.3,
                          style: BorderStyle.solid,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.5,
                          strokeAlign: 0.3,
                          style: BorderStyle.solid,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        color: Colors.white70,
                        onPressed: () {
                          _controller.clear();
                          setState(() => _lastQuery = "");
                          _searchCubit.search("");
                        },
                      ),
                      prefixIcon: Icon(Icons.search),
                      hintText: "Type movie name,title,etc",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      )),
                  onFieldSubmitted: (value) {
                    _lastQuery = value;
                    _searchCubit.search(value);
                  },
                  focusNode: _focusNode,
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Stack(
                    children: [
                      BlocBuilder<SearchCubit, SearchState>(
                        builder: (context, state) {
                          if (state is SearchInitial) {
                            return const Center(
                              child: Text(
                                "Start typing to search...",
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          } else if (state is SearchLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is SearchError) {
                            return Center(
                              child: Text(
                                state.message,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else if (state is SearchEmpty) {
                            return const Center(
                              child: Text(
                                "No results found",
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          } else if (state is SearchLoaded) {
                            final results = state.results;

                            return ListView.builder(
                              controller: _scrollController,
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final movie = results[index];
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
                              },
                            );
                          }
                          return const SizedBox();
                        },
                      ),

                      // Floating Load More Button
                      if (_showLoadMoreButton && _lastQuery.isNotEmpty)
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _showLoadMoreButton ? 1.0 : 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _isLoadingNext
                                    ? null
                                    : () async {
                                        _tryLoadNextPage();
                                        setState(
                                            () => _showLoadMoreButton = false);
                                      },
                                icon: _isLoadingNext
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                label: Text(
                                  _isLoadingNext ? 'Loading...' : 'Load More',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF47474a),
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Colors.red,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom pagination bar - positioned at screen bottom
        bottomNavigationBar: _lastQuery.isNotEmpty
            ? Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a2d), // Different background color
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border:
                      Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _searchCubit.currentPage > 1 &&
                                !_isLoadingNext
                            ? () async {
                                await _jumpToPage(_searchCubit.currentPage - 1,
                                    scrollToTop: true);
                                setState(() => _showLoadMoreButton = false);
                                if (mounted) _focusNode.requestFocus();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        color: _searchCubit.currentPage > 1
                            ? Colors.white
                            : Colors.grey,
                      ),
                      ...List.generate(5, (i) {
                        final center = _searchCubit.currentPage;
                        final page = math.max(1, center - 2) + i;
                        final selected = page == center;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: SizedBox(
                            width: 36,
                            height: 32,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    selected ? Colors.red : Colors.transparent,
                                side: BorderSide(
                                  color: selected ? Colors.red : Colors.grey,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                              ),
                              onPressed: (_isLoadingNext || selected)
                                  ? null
                                  : () async {
                                      await _jumpToPage(page,
                                          scrollToTop: true);
                                      setState(
                                          () => _showLoadMoreButton = false);
                                      if (mounted) _focusNode.requestFocus();
                                    },
                              child: Text(
                                page.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selected
                                      ? Colors.white
                                      : Colors.grey[300],
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      IconButton(
                        onPressed: !_isLoadingNext
                            ? () async {
                                await _jumpToPage(_searchCubit.currentPage + 1,
                                    scrollToTop: true);
                                setState(() => _showLoadMoreButton = false);
                                if (mounted) _focusNode.requestFocus();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
