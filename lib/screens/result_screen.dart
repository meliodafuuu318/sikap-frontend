import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/session.dart';
import '../services/firestore_service.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final List<Map<String, dynamic>> results;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.results,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveSessionToFirestore();
  }

  Future<void> _saveSessionToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final sessionId = FirebaseFirestore.instance.collection('dummy').doc().id;

    final session = Session(
      id: sessionId,
      score: widget.score,
      total: widget.total,
      timestamp: DateTime.now(),
    );

    await FirestoreService().saveSession(
      userId: user.uid,
      session: session,
      answeredQuestions: widget.results,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = widget.total == 0 ? 0 : widget.score / widget.total;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Review Complete'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight + 24),
              SizedBox(
                width: 200,
                height: 200,
                child: Column(
                  children: [
                    CustomPaint(
                      size: const Size(200, 100),
                      painter: SemiCirclePainter(
                        progress: progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        progressColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.score} / ${widget.total}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.results.length,
                  itemBuilder: (context, index) {
                    final result = widget.results[index];
                    final isCorrect = result['isCorrect'] as bool;
                    final options = List<String>.from(result['options']);
                    final correctIndex = result['correctIndex'] as int;

                    return Card(
                      color: isCorrect
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result['question'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('Your Answer: ${result['userAnswer']}'),
                            Text('Correct Answer: ${options[correctIndex]}'),
                            const SizedBox(height: 4),
                            Text(
                              isCorrect ? '✅ Correct' : '❌ Incorrect',
                              style: TextStyle(
                                color:
                                    isCorrect ? Colors.green : Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SemiCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  SemiCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint basePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final Rect arcRect = Rect.fromLTWH(0, 0, size.width, size.height * 2);

    canvas.drawArc(arcRect, math.pi, math.pi, false, basePaint);
    canvas.drawArc(arcRect, math.pi, math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
