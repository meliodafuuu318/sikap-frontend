class Session {
  final String id;
  final DateTime timestamp;
  final int score;
  final int total;

  Session({
    required this.id,
    required this.timestamp,
    required this.score,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'score': score,
      'total': total,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      score: map['score'],
      total: map['total'],
    );
  }
}
