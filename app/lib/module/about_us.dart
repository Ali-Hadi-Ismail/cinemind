import 'package:flutter/material.dart';
import 'package:cinemind/shared/theme/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About CineMind",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App logo (optional)
              Center(
                child: Icon(
                  Icons.movie_creation_outlined,
                  size: 80,
                  color: CineMindTheme.primaryRed,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Our Story",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: CineMindTheme.primaryRed,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                "CineMind was born out of a simple frustration: we love movies and TV shows, "
                "but keeping track of what we watched, what we loved, and what we want to explore next was messy. "
                "We wanted one clean place to bring order to our cinematic world — and that’s how CineMind started.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),

              Text(
                "Why We Built It",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                "We believe cinema isn’t just entertainment — it’s memory, culture, and inspiration. "
                "CineMind helps you keep your favorites close, discover new gems, and never lose track of what matters to you.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),

              Text(
                "Our Mission",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                "We’re here to make your movie and series journey effortless. "
                "From tracking your favorites to exploring fresh titles — CineMind is your companion, "
                "built by people who love stories as much as you do.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),

              Text(
                "Made by Devloopmint",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                "A team of developers, dreamers, and storytellers who believe in building tools that "
                "help people learn, enjoy, and connect.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),

              Center(
                child: Text(
                  "Thank you for being part of our journey ❤️",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: CineMindTheme.primaryRed,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
