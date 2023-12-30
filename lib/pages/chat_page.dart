// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ChatPage extends StatefulWidget {
//   final String userId;
//   final String userName;
//
//   const ChatPage({Key? key, required this.userId, required this.userName}) : super(key: key);
//
//   @override
//   _ChatPageState createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> {
//   TextEditingController messageController = TextEditingController();
//   List<Widget> messageWidgets = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat avec ${widget.userName}'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('messages')
//                   .where('from', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
//                   .where('to', isEqualTo: widget.userId)
//                   // .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 try {
//                   if (!snapshot.hasData) {
//                     return Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }
//
//                   var messagesSent = snapshot.data!.docs;
//
//                   return StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('messages')
//                         .where('from', isEqualTo: widget.userId)
//                         .where('to', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
//                         // .orderBy('timestamp', descending: true)
//                         .snapshots(),
//                     builder: (context, snapshotReceived) {
//                       if (!snapshotReceived.hasData) {
//                         return Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       }
//                       var messagesReceived = snapshotReceived.data!.docs;
//                       var allMessages = [...messagesSent, ...messagesReceived];
//
//                       allMessages.sort((a, b) {
//                         var timestampA = a['timestamp'] as Timestamp?;
//                         var timestampB = b['timestamp'] as Timestamp?;
//
//                         if (timestampA == null && timestampB == null) {
//                           return 0;
//                         } else if (timestampA == null) {
//                           return 1;
//                         } else if (timestampB == null) {
//                           return -1;
//                         } else {
//                           return timestampB.compareTo(timestampA);
//                         }
//                       });
//
//
//                       return ListView.builder(
//                         reverse: true,
//                         itemCount: allMessages.length,
//                         itemBuilder: (context, index) {
//                           var messageText = allMessages[index]['content'];
//                           var messageSender = allMessages[index]['from'];
//                           print(allMessages);
//                           // var displayName = await getDisplayName(messageSender);
//
//                           return MessageWidget(messageSender, messageText);
//                         },
//                       );
//                     },
//                   );
//                 } catch (e) {
//                   print('Error in StreamBuilder: $e');
//                   return Center(
//                     child: Text('An error occurred. Please check logs for details.'),
//                   );
//                 }
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Entrer un message...',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () {
//                     sendMessage();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void sendMessage() {
//     if (messageController.text.isNotEmpty) {
//       FirebaseFirestore.instance.collection('messages').add({
//         'content': messageController.text,
//         'from': FirebaseAuth.instance.currentUser?.uid,
//         'to': widget.userId,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//       messageController.clear();
//     }
//   }
//
//   Future<String?> getDisplayName(String userId) async {
//     try {
//       // Utilisez la méthode get() pour récupérer le document correspondant à l'ID dans la collection "users"
//       DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
//
//       // Vérifiez si le document existe
//       if (userSnapshot.exists) {
//         // Récupérez le champ 'displayName' du document
//         String displayName = userSnapshot.get('displayName');
//         return displayName;
//       } else {
//         // L'utilisateur n'existe pas
//         return null;
//       }
//     } catch (e) {
//       // Gérer les erreurs éventuelles
//       print('Erreur lors de la récupération du displayName : $e');
//       return null;
//     }
//   }
//
//   // Future<String?> getCurrentUserName() async {
//   //
//   //   String? userId = FirebaseAuth.instance.currentUser?.uid;
//   //   QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
//   //       .collection('users')
//   //       .where('id', isEqualTo: userId)
//   //       .get();
//   //
//   //   if (querySnapshot.docs.isNotEmpty) {
//   //     return querySnapshot.docs.first['displayName'];
//   //   } else {
//   //     return null;
//   //   }
//   // }
//
// }
//
// class MessageWidget extends StatelessWidget {
//   final String sender;
//   final String text;
//
//   MessageWidget(this.sender, this.text);
//
//   @override
//   Widget build(BuildContext context) {
//     final isCurrentUser = FirebaseAuth.instance.currentUser?.uid == sender;
//
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Align(
//         alignment: isCurrentUser ? Alignment.topRight : Alignment.topLeft,
//         child: Container(
//           padding: const EdgeInsets.all(8.0),
//           decoration: BoxDecoration(
//             color: isCurrentUser ? Colors.blue : Colors.grey,
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 sender,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: isCurrentUser ? Colors.white : Colors.black,
//                 ),
//               ),
//               Text(
//                 text,
//                 style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
