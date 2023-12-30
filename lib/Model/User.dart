import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String displayName;
  final String? bio;

  User({
    required this.id,
    required this.displayName,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'bio': bio,
    };
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      displayName: doc['displayName'],
      bio: doc['bio'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'bio': bio,
    };
  }
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      displayName: json['displayName'],
      bio: json['bio'],
    );
  }

  @override
  String toString() {
    return 'Nom: $displayName, Bio: ${bio ?? "Non disponible"}';
  }
}