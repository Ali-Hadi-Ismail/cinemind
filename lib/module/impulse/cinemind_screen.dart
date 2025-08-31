import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CineMindScreen extends StatefulWidget {
  const CineMindScreen({super.key});

  @override
  State<CineMindScreen> createState() => _CineMindScreenState();
}

class _CineMindScreenState extends State<CineMindScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Color currentGradientStart = const Color(0xFF1A1A2E);
  Color currentGradientEnd = const Color(0xFF16213E);
  Color targetGradientStart = const Color(0xFF2D1B69);
  Color targetGradientEnd = const Color(0xFF11998E);

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _gradientController.addListener(() {
      setState(() {
        currentGradientStart = Color.lerp(
          currentGradientStart,
          targetGradientStart,
          _gradientController.value,
        )!;
        currentGradientEnd = Color.lerp(
          currentGradientEnd,
          targetGradientEnd,
          _gradientController.value,
        )!;
      });
    });

    // Start animations
    _gradientController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startQuestionnaire() {
    // TODO: Navigate to questionnaire screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting questionnaire...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                currentGradientStart,
                currentGradientStart.withOpacity(0.8),
                currentGradientEnd,
                currentGradientEnd.withOpacity(0.6),
                Colors.black.withOpacity(0.8),
              ],
              stops: const [0.0, 0.2, 0.5, 0.7, 1.0],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(100), // 👈 set custom height
              child: AppBar(
                  centerTitle: true,
                  title: Center(
                    child: SizedBox(
                      width: 200,
                      child: Image.asset(
                        'asset/images/logo_dark_transparent.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  )),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildPurposeSection(),
                      const SizedBox(height: 30),
                      _buildRulesSection(),
                      const SizedBox(height: 40),
                      _buildStartButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPurposeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CineMindTheme.primaryRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.movie_filter,
            size: 48,
            color: CineMindTheme.primaryRed,
          ),
          const SizedBox(height: 16),
          Text(
            "Find Your Perfect Movie Tonight",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            "Let CineMind analyze your preferences through a personalized questionnaire and discover the perfect movie recommendation tailored just for you.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade300,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rule,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "How It Works",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRuleItem(
            "📝",
            "Answer 10-20 quick questions about your movie preferences",
          ),
          _buildRuleItem(
            "🎯",
            "Questions cover genres, mood, cast preferences, and viewing habits",
          ),
          _buildRuleItem(
            "⏱️",
            "Takes only 3-5 minutes to complete",
          ),
          _buildRuleItem(
            "🎬",
            "Get a personalized movie recommendation perfect for tonight",
          ),
          _buildRuleItem(
            "✨",
            "Be honest with your answers for the best results",
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade300,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CineMindTheme.primaryRed,
                  CineMindTheme.primaryRed.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: CineMindTheme.primaryRed.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _startQuestionnaire,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Start CineMind Journey",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
