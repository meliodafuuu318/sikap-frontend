import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SessionDetailScreen extends StatelessWidget {
  final String userId;
  final String sessionId;

  const SessionDetailScreen({
    super.key,
    required this.userId,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Session Details'),
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
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('sessions')
                      .doc(sessionId)
                      .collection('questions')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error loading questions'));
                    }

                    final questions = snapshot.data?.docs ?? [];

                    if (questions.isEmpty) {
                      return const Center(
                        child: Text(
                          'No questions found for this session.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final data =
                            questions[index].data() as Map<String, dynamic>;
                        final options = List<String>.from(data['options']);
                        final correctIndex = data['correctIndex'] ?? 0;
                        final userAnswer = data['userAnswer'] ?? '';
                        final isCorrect = data['isCorrect'] ?? false;

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
                                  data['question'] ?? 'No question',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('Your Answer: $userAnswer'),
                                Text(
                                    'Correct Answer: ${options[correctIndex]}'),
                                const SizedBox(height: 4),
                                Text(
                                  isCorrect ? '✅ Correct' : '❌ Incorrect',
                                  style: TextStyle(
                                    color: isCorrect
                                        ? Colors.green
                                        : Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
