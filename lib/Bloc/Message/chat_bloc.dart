import 'dart:async';

import 'chat_repository.dart';

class ChatBloc {
  final _messageController = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get messagesStream => _messageController.stream;

  final _repository = ChatRepository();

  void getMessages(String userId) async {
    _repository.getMessages(userId).listen((messages) {
      _messageController.add(messages);
    });
  }

  void sendMessage(String content, String toUserId) {
    _repository.sendMessage(content, toUserId);
  }

  void dispose() {
    _messageController.close();
  }
}

final chatBloc = ChatBloc();
