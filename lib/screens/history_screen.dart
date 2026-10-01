import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'session_detail_screen.dart';

class SessionHistoryScreen extends StatelessWidget {
  final String userId;

  const SessionHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('sessions')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading sessions'));
            }

            final sessions = snapshot.data?.docs ?? [];

            if (sessions.isEmpty) {
              return const Center(child: Text('No session history found.'));
            }

            return ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index].data() as Map<String, dynamic>;
                final timestamp = session['timestamp'];
                String formattedDate;

                if (timestamp is Timestamp) {
                  formattedDate = timestamp.toDate().toString();
                } else if (timestamp is String) {
                  formattedDate = timestamp;
                } else {
                  formattedDate = 'Unknown date';
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      'Score: ${session['score'] ?? 0} / ${session['total'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Completed: $formattedDate',
                      style: const TextStyle(fontSize: 13),
                    ),
                    onTap: () {
                      final sessionId = sessions[index].id;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessionDetailScreen(
                            userId: userId,
                            sessionId: sessionId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
