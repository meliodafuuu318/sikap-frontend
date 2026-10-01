import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Flashcards',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoadingScreen(), // Show loading screen first
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int filledBoxes = 0;
  late Timer timer;
  int animationLoops = 0; // To count the number of animation loops

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      setState(() {
        filledBoxes++;
        if (filledBoxes > 8) {
          filledBoxes = 0; // Reset box animation after it completes
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _goToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6T8gslBzcjQ4TkiY22z1Eox1F1V0gLymTsQ&usqp=CAU',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Text for "LOADING" with loop
              AnimatedText(
                text: "LOADING",
                duration: const Duration(milliseconds: 500),
                onLoopComplete: () {
                  // Once the animation loops twice, navigate to the home screen
                  setState(() {
                    animationLoops++;
                  });

                  if (animationLoops >= 2) {
                    _goToHomeScreen();
                  }
                },
              ),
              const SizedBox(height: 20),
              // Box animation with loop
              Container(
                width: 200,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 4),
                ),
                child: Row(
                  children: List.generate(8, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.all(2),
                      width: 20,
                      height: 20,
                      color: index < filledBoxes
                          ? Colors.black
                          : Colors.transparent,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom AnimatedText widget that animates each letter one by one
class AnimatedText extends StatefulWidget {
  final String text;
  final Duration duration;
  final VoidCallback onLoopComplete;

  const AnimatedText({
    Key? key,
    required this.text,
    required this.duration,
    required this.onLoopComplete,
  }) : super(key: key);

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  late List<String> _characters;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _characters = widget.text.split('');
    _startAnimation();
  }

  // Start the animation and loop it
  void _startAnimation() {
    Future.delayed(widget.duration, () {
      if (_currentIndex < _characters.length) {
        setState(() {
          _currentIndex++;
        });
        _startAnimation(); // Continue animating the next character
      } else {
        // Once all characters are displayed, reset the animation
        setState(() {
          _currentIndex = 0;
        });

        // Trigger loop complete callback
        widget.onLoopComplete();

        _startAnimation(); // Restart the animation
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _characters.sublist(0, _currentIndex).join(),
      style: const TextStyle(
        fontFamily: 'PixelifySans',
        fontSize: 40,
        color: Colors.black,
        letterSpacing: 2,
      ),
    );
  }
}
