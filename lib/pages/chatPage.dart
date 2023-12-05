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

                  var messagesSent = snapshot.data!.docs;

                  // Charger les messages reçus
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('messages')
                        .where('from', isEqualTo: widget.userId)
                        .where('to', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        // .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshotReceived) {
                      if (!snapshotReceived.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      var messagesReceived = snapshotReceived.data!.docs;

                      // Combiner les messages envoyés et reçus dans une seule liste
                      var allMessages = [...messagesSent, ...messagesReceived];

                      // Trier la liste combinée par timestamp
                      allMessages.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

                      return ListView.builder(
                        reverse: true,
                        itemCount: allMessages.length,
                        itemBuilder: (context, index) {
                          var messageText = allMessages[index]['content'];
                          var messageSender = allMessages[index]['from'];

                          return MessageWidget(messageSender, messageText);
                        },
                      );
                    },
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

  // Future<void> loadMessages() async {
  //   var messages = await FirebaseFirestore.instance
  //       .collection('messages')
  //       .where('from', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
  //       .where('to', isEqualTo: widget.userId)
  //       .get();
  //
  //   for (var message in messages.docs) {
  //     var messageText = message['content'];
  //
  //     var displayName = await getCurrentUserName();
  //     print(displayName);
  //
  //     if (_isMounted) {
  //       var messageWidget = MessageWidget(displayName ?? 'Unknown User', messageText);
  //       setState(() {
  //         messageWidgets.add(messageWidget);
  //       });
  //     }
  //   }
  // }

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
