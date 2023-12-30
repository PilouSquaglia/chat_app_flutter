import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String from;
  final String to;
  final String content;
  final Timestamp timestamp;

  Message({
    required this.from,
    required this.to,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'content': content,
      'timestamp': timestamp,
    };
  }
  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      from: doc['from'],
      to: doc['to'],
      content: doc['content'],
      timestamp: doc['timestamp'],
    );
  }
}