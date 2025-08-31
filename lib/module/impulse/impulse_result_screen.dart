import 'package:cinemind/module/detail/movie_detail_screen.dart';
import 'package:cinemind/shared/constant/phrase.dart';
import 'package:cinemind/shared/service/movie_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fireworks/flutter_fireworks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../shared/service/open_ai_service.dart';
import '../../shared/service/search_service.dart';
import '../../model/movie.dart';

class ImpulseResultScreen extends StatefulWidget {
  final String answers;
  const ImpulseResultScreen({super.key, required this.answers});

  @override
  State<ImpulseResultScreen> createState() => _ImpulseResultScreenState();
}

class _ImpulseResultScreenState extends State<ImpulseResultScreen>
    with TickerProviderStateMixin {
  final OpenAIService _openAIService = OpenAIService();
  final SearchService _searchService = SearchService();
  late FireworksController _fireworksController;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentPhraseIndex = 0;
  String? _responseText;
  List<Movie> _movies = [];
  final PageController _pageController = PageController(viewportFraction: 0.85);
  bool _isLoadingMovieDetail = false;

  @override
  void initState() {
    super.initState();
    _fireworksController = FireworksController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _responseText == null) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _currentPhraseIndex =
                  (_currentPhraseIndex + 1) % Phrase().loadingPhrases.length;
            });
            _fadeController
              ..reset()
              ..forward();
          }
        });
      }
    });
    _fadeController.forward();
    _getRecommendation();
  }

  Future<void> _getRecommendation() async {
    final response = await _openAIService.sendPrompt(widget.answers);
    final movieTitles = parseMovies(response);
    List<Movie> movies = [];
    for (var title in movieTitles.take(3)) {
      final results = await _searchService.fetchSearchMovie(query: title);
      if (results.isNotEmpty) movies.add(results.first);
    }
    if (mounted) {
      setState(() {
        _responseText = response;
        _movies = movies;
      });
      // Trigger fireworks after movies are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fireworksController.fireMultipleRockets(maxRockets: 5);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted)
              _fireworksController.fireMultipleRockets(maxRockets: 5);
          });
        }
      });
    }
  }

  List<String> parseMovies(String text) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty);
    return lines.map((line) {
      final regex = RegExp(r'^(.*)\s\((\d{4})\)$');
      final match = regex.firstMatch(line);
      if (match != null) return match.group(1)!.trim();
      return line.trim();
    }).toList();
  }

  Future<void> _onMovieTap(Movie movie) async {
    setState(() {
      _isLoadingMovieDetail = true;
    });

    try {
      Movie? movieDetail = await MovieService().fetchMovieById(movie.id);
      if (mounted) {
        setState(() {
          _isLoadingMovieDetail = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movie: movieDetail!),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMovieDetail = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load movie details')),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    _fireworksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Your Movies Recommendations",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.redAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: _responseText == null
                ? Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          Phrase().loadingPhrases[_currentPhraseIndex],
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          Phrase().sarcasticTexts[_movies.isNotEmpty
                              ? _movies.length % Phrase().sarcasticTexts.length
                              : 0],
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _movies.isEmpty
                            ? const Center(
                                child: Text(
                                  "No movies found... even AI gave up on you",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            : PageView.builder(
                                controller: _pageController,
                                itemCount: _movies.length,
                                itemBuilder: (context, index) {
                                  final movie = _movies[index];
                                  return GestureDetector(
                                    onTap: () => _onMovieTap(movie),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  width: 2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.8),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 8),
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              child: movie.posterPath.isNotEmpty
                                                  ? Image.network(
                                                      "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                                                      fit: BoxFit.cover,
                                                      height: 400,
                                                      width: double.infinity,
                                                      loadingBuilder: (context,
                                                          child, progress) {
                                                        if (progress == null)
                                                          return child;
                                                        return Container(
                                                          height: 400,
                                                          color:
                                                              Colors.grey[800],
                                                          child: const Center(
                                                            child:
                                                                SpinKitHourGlass(
                                                                    color: Colors
                                                                        .red,
                                                                    size: 30),
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          height: 400,
                                                          color:
                                                              Colors.grey[800],
                                                          child: const Center(
                                                            child: Icon(
                                                                Icons.movie,
                                                                size: 80,
                                                                color: Colors
                                                                    .white54),
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Container(
                                                      height: 400,
                                                      color: Colors.grey[800],
                                                      child: const Center(
                                                        child: Icon(Icons.movie,
                                                            size: 80,
                                                            color:
                                                                Colors.white54),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            movie.title,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.2),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            movie.releaseDate.isNotEmpty
                                                ? "Released: ${movie.releaseDate.split('-').first}"
                                                : "Unknown release",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: Colors.grey[300],
                                                    fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                size: 22, color: Colors.white),
                            label: const Text("Back to Impulsive Screen",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.9),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Loading overlay for movie details
          if (_isLoadingMovieDetail)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpinKitHourGlass(color: Colors.redAccent, size: 60),
                    SizedBox(height: 24),
                    Text(
                      "Loading movie details...",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

          // Fireworks layer
          Positioned.fill(
              child: FireworksDisplay(controller: _fireworksController)),
        ],
      ),
    );
  }
}
