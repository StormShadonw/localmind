class LocalMessage {
  String author;
  String message;
  final DateTime timestamp;

  LocalMessage({
    required this.author,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocalMessage.fromMap(Map<String, dynamic> map) {
    return LocalMessage(
      author: map['author'] ?? '',
      message: map['message'] ?? '',
      timestamp:
          map['timestamp'] != null
              ? DateTime.parse(map['timestamp'])
              : DateTime.now(),
    );
  }
}
