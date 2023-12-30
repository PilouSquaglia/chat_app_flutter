import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat_bloc.dart';
import 'chat_repository.dart';
import 'message_widget.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatPage({Key? key, required this.userId, required this.userName})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  final chatRepository = ChatRepository();

  late ChatBloc chatBloc;

  @override
  void initState() {
    super.initState();
    chatBloc = ChatBloc();
    chatBloc.getMessages(widget.userId);
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: chatBloc.messagesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                List<Map<String, dynamic>> allMessages = snapshot.data!;

                allMessages.sort((a, b) {
                  var timestampA = (a as Map<String, dynamic>)['timestamp'] as Timestamp?;
                  var timestampB = (b as Map<String, dynamic>)['timestamp'] as Timestamp?;

                  if (timestampA == null && timestampB == null) {
                    return 0;
                  } else if (timestampA == null) {
                    return 1;
                  } else if (timestampB == null) {
                    return -1;
                  } else {
                    return timestampB.compareTo(timestampA);
                  }
                });

                return ListView.builder(
                  reverse: true,
                  itemCount: allMessages.length,
                  itemBuilder: (context, index) {
                    var messageText = (allMessages[index] as Map<String, dynamic>)['content'];
                    var messageSender = (allMessages[index] as Map<String, dynamic>)['from'];

                    print(allMessages);
                    // var displayName = await getDisplayName(messageSender);

                    return MessageWidget(messageSender, messageText);
                  },
                );
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
                    chatBloc.sendMessage(messageController.text, widget.userId);
                    messageController.clear();
                  },
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    chatBloc.dispose();
    super.dispose();
  }
}
