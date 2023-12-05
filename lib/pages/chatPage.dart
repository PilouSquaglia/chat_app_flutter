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
  List<Widget> messageWidgets = [];
  bool _isMounted = false;

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _isMounted = true;
    loadMessages();
  }

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
              .where('from', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .where('to', isEqualTo: widget.userId)
              // .orderBy('timestamp', descending: true)
              .snapshots(),
              builder: (context, snapshot) {
                try {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // List<Widget> messageWidgets = [];
                  // for (var message in messages) {
                  //   var messageText = message['content'];
                  //   var messageSender = message['from'];
                  //
                  //   var messageWidget = MessageWidget(messageSender, messageText);
                  //   messageWidgets.add(messageWidget);
                  // }

                  loadMessages();

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

  Future<void> loadMessages() async {
    var messages = await FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('to', isEqualTo: widget.userId)
        .get();

    for (var message in messages.docs) {
      var messageText = message['content'];

      var displayName = await getCurrentUserName();

      if (_isMounted) {
        var messageWidget = MessageWidget(displayName ?? 'Unknown User', messageText);
        setState(() {
          messageWidgets.add(messageWidget);
        });
      }
    }
  }

  Future<String?> getCurrentUserName() async {

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['displayName'];
    } else {
      return null;
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
