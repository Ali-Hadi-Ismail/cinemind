import 'package:cinemind/shared/service/open_ai_service.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:flutter/material.dart';

class ImpulseScreen extends StatefulWidget {
  const ImpulseScreen({super.key});

  @override
  State<ImpulseScreen> createState() => _ImpulseScreenState();
}

class _ImpulseScreenState extends State<ImpulseScreen> {
  String? _selectedOption;
  bool _loading = false;
  String _response = "";

  // Fixed options
  final List<String> _options = [
    "CineSwipe",
    "Watch List",
    "Favorite",
    "Trending",
    "Popular",
    "Top Coming"
  ];

  void _selectOption(String option) async {
    setState(() {
      _selectedOption = option;
      _loading = true;
      _response = "";
    });

    if (option == "CineSwipe") {
      try {
        final resp = await OpenAIService().sendPrompt(
            "Recommend a movie based on user preferences for CineSwipe");
        setState(() {
          _response = resp;
        });
      } catch (e) {
        setState(() {
          _response = "Error: $e";
        });
      } finally {
        setState(() {
          _loading = false;
        });
      }
    } else {
      // Simulate response for other options
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        _response = "$option content loaded!";
        _loading = false;
      });
    }
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
                  fontSize: 16,
                  color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey),
            SizedBox(height: 10),

            // Grid of options
            Expanded(
              child: GridView.builder(
                itemCount: _options.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 3 / 3, // taller to fit image + name
                ),
                itemBuilder: (context, index) {
                  final option = _options[index];
                  final isSelected = option == _selectedOption;

                  return GestureDetector(
                    onTap: () => _selectOption(option),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isSelected
                                ? CineMindTheme.cardDark
                                : Colors.grey.shade400,
                            width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(13)),
                              child: Image.asset(
                                "assets/images/${option.toLowerCase().replaceAll(' ', '')}.png",
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? CineMindTheme.cardDark
                                    : Colors.grey[800],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Show loading or response
            if (_loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: CircularProgressIndicator(),
              ),
            if (!_loading && _response.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _response,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
