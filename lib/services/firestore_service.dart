import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserIfNotExists({
    required String uid,
    required String email,
  }) async {
    final userRef = _db.collection('users').doc(uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'uid': uid,
        'email': email,
      });
    }
  }

  Future<void> saveSession({
    required String userId,
    required Session session,
    required List<Map<String, dynamic>> answeredQuestions,
  }) async {
    final sessionRef = _db
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(session.id);

    await sessionRef.set(session.toMap());

    final questionsRef = sessionRef.collection('questions');

    for (var answered in answeredQuestions) {
      await questionsRef.add({
        'question': answered['question'],
        'options': List<String>.from(answered['options']),
        'correctIndex': answered['correctIndex'],
        'userAnswer': answered['userAnswer'],
        'isCorrect': answered['isCorrect'],
      });
    }
  }
}
