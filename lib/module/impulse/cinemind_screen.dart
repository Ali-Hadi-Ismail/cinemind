// ignore: unused_import
import 'package:cinemind/shared/service/open_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../shared/utils/impulse_question_generating.dart';
import 'impulse_question_screen.dart';

class CineMindScreen extends StatefulWidget {
  const CineMindScreen({super.key});

  @override
  State<CineMindScreen> createState() => _CineMindScreenState();
}

class _CineMindScreenState extends State<CineMindScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  void startQuestionnaire() {
    final questions =
        getQuestionToAsk(); // your function returning List<ImpulseQuestion>

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImpulseQuestionnaireScreen(
          questions: questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Impulse",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildPurposeSection(context),
                const SizedBox(height: 25),
                _buildRulesSection(context),
                const SizedBox(height: 25),
                _buildStartButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurposeSection(BuildContext context) {
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade300,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CineMindTheme.primaryRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.rule,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "How It Works",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
              context),
          _buildRuleItem(
              "🎯",
              "Questions cover genres, mood, cast preferences, and viewing habits",
              context),
          _buildRuleItem("⏱️", "Takes only 1-3 minutes to complete", context),
          _buildRuleItem(
              "🎬",
              "Get a personalized movie recommendation perfect for tonight",
              context),
          _buildRuleItem(
              "✨", "Be honest with your answers for the best results", context),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String emoji, String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
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

  Widget _buildStartButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: startQuestionnaire,
        style: ElevatedButton.styleFrom(
          backgroundColor: CineMindTheme.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 8,
          shadowColor: CineMindTheme.primaryRed.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              "Start CineMind Journey",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
