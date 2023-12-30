import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superchat/constants.dart';
import 'package:superchat/pages/sign_in_page.dart';
import 'package:superchat/widgets/stream_listener.dart';

import '../Bloc/Message/chat_page.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  Future<String> getUserData(String userId) async {
    try {
      final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: userId)
          .get();

      if (userSnapshot.docs.first['displayName'].exists) {
        final String userName = userSnapshot.docs.first['displayName'];
        return 'Name: $userName';
      } else {
        return 'User not found';
      }
    } catch (e) {
      print('Error getting user data: $e');
      return 'Error getting user data';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamListener<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      listener: (user) {
        if (user == null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SignInPage()),
                (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(kAppTitle),
          backgroundColor: theme.colorScheme.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Colors.blue,
              height: 250,
              child: Center(
                child: StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      final User? user = snapshot.data;
                      if (user != null) {
                        var userName = getUserData(user.uid);
                        // print(userName.toString());
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('User ID: ${user.uid}'),
                            Text('Name: ${userName}'),
                          ],
                        );
                      } else {
                        return Text('User not logged in');
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ),
            ),
            const Spacer(flex: 1),
            Container(
              color: Colors.blue,
              height: 500,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    final List<DocumentSnapshot> documents = snapshot.data?.docs ?? [];

                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic>? data = documents[index].data() as Map<String, dynamic>?;

                        if (data != null) {
                          final String userId = data['id'] ?? '';
                          // print(userId);
                          final String userName = data['displayName'];

                          return InkWell(
                            onTap: () {
                              // Navigate to the ChatPage with the selected user
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    userId: userId,
                                    userName: userName,
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text('Chatter avec : $userName'),
                            ),
                          );
                        } else {
                          return ListTile(
                            title: Text('Error retrieving user data'),
                          );
                        }
                      },
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
