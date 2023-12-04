class ChatUser {
  final String id;
  final String displayName;
  final String? bio;

  ChatUser({
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

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      displayName: json['displayName'],
      bio: json['bio'],
    );
  }
}