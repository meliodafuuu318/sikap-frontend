import 'package:flutter/material.dart';
import '../models/question.dart';
import 'result_screen.dart';

class ReviewScreen extends StatefulWidget {
  final List<Question> questions;

  const ReviewScreen({super.key, required this.questions});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _currentIndex = 0;
  int _score = 0;
  final List<Map<String, dynamic>> _results = [];

  void _answer(int selectedIndex) {
    final current = widget.questions[_currentIndex];
    final correctIndex = current.correctIndex;

    bool isCorrect = selectedIndex == correctIndex;
    if (isCorrect) _score++;

    _results.add({
      'question': current.question,
      'options': current.options,
      'correctIndex': current.correctIndex,
      'userAnswer': current.options[selectedIndex],
      'isCorrect': isCorrect,
    });

    if (_currentIndex < widget.questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: _score,
            total: widget.questions.length,
            results: _results,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1}/${widget.questions.length}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6T8gslBzcjQ4TkiY22z1Eox1F1V0gLymTsQ&usqp=CAU',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: kToolbarHeight + 24),

                    // Question Card
                    Card(
                      color: Colors.white.withOpacity(0.85),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Answer Buttons using Wrap
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(question.options.length, (index) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 80) / 2,
                          child: ElevatedButton(
                            onPressed: () => _answer(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              foregroundColor: Colors.black,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                            ),
                            child: Text(
                              question.options[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
