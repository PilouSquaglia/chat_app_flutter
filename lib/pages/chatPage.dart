import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatPage({Key? key, required this.userId, required this.userName}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat avec ${widget.userName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('from', whereIn: [
                FirebaseAuth.instance.currentUser?.uid,
                widget.userId,
              ])
                  .snapshots(),
              builder: (context, snapshot) {
                try {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var messages = snapshot.data!.docs;

                  List<Widget> messageWidgets = [];
                  for (var message in messages) {
                    var messageText = message['content'];
                    var messageSender = message['from'];

                    var messageWidget = MessageWidget(messageSender, messageText);
                    messageWidgets.add(messageWidget);
                  }

                  return ListView(
                    reverse: true,
                    children: messageWidgets,
                  );
                } catch (e) {
                  print('Error in StreamBuilder: $e');
                  return Center(
                    child: Text('An error occurred. Please check logs for details.'),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Entrer un message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('messages').add({
        'content': messageController.text,
        'from': FirebaseAuth.instance.currentUser?.uid,
        'to': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      messageController.clear();
    }
  }
}

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;

  MessageWidget(this.sender, this.text);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = FirebaseAuth.instance.currentUser?.uid == sender;

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
                sender,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? Colors.white : Colors.black,
                ),
              ),
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
