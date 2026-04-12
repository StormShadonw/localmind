class LocalMessage {
  String author;
  String message;

  LocalMessage({required this.author, required this.message});

  Map<String, dynamic> toMap() {
    return {'author': author, 'message': message};
  }

  factory LocalMessage.fromMap(Map<String, dynamic> map) {
    return LocalMessage(
      author: map['author'] ?? '',
      message: map['message'] ?? '',
    );
  }
}
