import 'package:cinemind/module/impulse/cinemind_screen.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:flutter/material.dart';

class ImpulseScreen extends StatefulWidget {
  const ImpulseScreen({super.key});

  @override
  State<ImpulseScreen> createState() => _ImpulseScreenState();
}

class _ImpulseScreenState extends State<ImpulseScreen> {
  // Fixed options
  final List<String> _options = [
    "CineMind",
    "Watchlist",
    "Favorite",
    "Trending",
    "Popular",
  ];

  void _selectOption(String option) {
    setState(() {
      switch (option.toLowerCase()) {
        case "Impulse":
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CineMindScreen()));
          break;
        case "watchlist":
          break;
        case "favorite":
          break;
        case "trending":
          break;
        case "popular":
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Impulse",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Catchy phrase
            Text(
              "\"Scrolled for hours, still can’t decide? Relax, we’ll pretend it’s your choice (actually, it’s ours).\"",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey[400]),
            const SizedBox(height: 10),

            // Grid of clickable options
            Expanded(
              child: GridView.builder(
                itemCount: _options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 3 / 3, // square-ish
                ),
                itemBuilder: (context, index) {
                  final option = _options[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _selectOption(option),
                    splashColor: CineMindTheme.primaryRed.withOpacity(0.2),
                    highlightColor: CineMindTheme.cardDark.withOpacity(0.1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.25), // subtle border
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.12), // soft shadow
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: const Offset(0, 3), // slight lift
                          ),
                          BoxShadow(
                            color: CineMindTheme.primaryRed.withOpacity(0.08),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 6), // faint red glow
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: Image.asset(
                                "asset/images/impulse/${option.toLowerCase()}.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              option,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: CineMindTheme.whiteText,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
