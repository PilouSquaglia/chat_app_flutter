import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getMessages(String userId) {
    return _firestore
        .collection('messages')
        .where(Filter.or(
        Filter.and(
          Filter('from', isEqualTo: _auth.currentUser?.uid),
          Filter('to', isEqualTo: userId),
        ),
        Filter.and(
          Filter('from', isEqualTo: userId),
          Filter('to', isEqualTo: _auth.currentUser?.uid),
        )))
        .snapshots()
        .map((snapshot) {
      var messagesSent = snapshot.docs.map((doc) => doc.data()).toList();
      return messagesSent;
    });
  }

  void sendMessage(String content, String toUserId) {
    _firestore.collection('messages').add({
      'content': content,
      'from': _auth.currentUser?.uid,
      'to': toUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
