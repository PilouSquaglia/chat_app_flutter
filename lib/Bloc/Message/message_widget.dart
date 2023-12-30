import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../User/user_repository.dart';

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;
  final UserRepository userRepository = UserRepository();

  MessageWidget(this.sender, this.text);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = FirebaseAuth.instance.currentUser?.uid == sender;
    final isCurrentUserDisplayName = isCurrentUser
        ? FirebaseAuth.instance.currentUser?.displayName ?? ''
        : '';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: isCurrentUser ? Alignment.topRight : Alignment.topLeft,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
