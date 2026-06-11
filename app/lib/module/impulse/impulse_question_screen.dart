import 'package:flutter/material.dart';
import '../../model/impulse_question.dart';
import 'impulse_result_screen.dart';

class ImpulseQuestionnaireScreen extends StatefulWidget {
  final List<ImpulseQuestion> questions;

  const ImpulseQuestionnaireScreen({super.key, required this.questions});

  @override
  State<ImpulseQuestionnaireScreen> createState() =>
      _ImpulseQuestionnaireScreenState();
}

class _ImpulseQuestionnaireScreenState extends State<ImpulseQuestionnaireScreen>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  String answers = "";
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _selectChoice(int choiceIndex) {
    answers += " ${widget.questions[currentIndex].choices[choiceIndex]} ,";

    if (currentIndex < widget.questions.length - 1) {
      _fadeController.reverse().then((_) {
        setState(() {
          currentIndex++;
        });
        _fadeController.forward();
      });
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => ImpulseResultScreen(answers: answers),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / widget.questions.length,
                  backgroundColor: Colors.grey[800],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),

              // Question number
              Text(
                "Question ${currentIndex + 1} of ${widget.questions.length}",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey[400]),
              ),
              const SizedBox(height: 20),

              // Question + choices
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Question text
                        Text(
                          question.question,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 40),

                        // Choices
                        Column(
                          children: List.generate(question.choices.length, (i) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: GestureDetector(
                                onTap: () => _selectChoice(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.shade700,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      )
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 16),
                                  child: Center(
                                    child: Text(
                                      question.choices[i],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
