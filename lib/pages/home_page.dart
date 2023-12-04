import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superchat/constants.dart';
import 'package:superchat/pages/sign_in_page.dart';
import 'package:superchat/widgets/stream_listener.dart';

import 'chatPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  Future<String> getUserData(String userId) async {
    try {
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        final Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        final String userName = userData['displayName'] ?? '';
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
                        return Text('User ID: ${user.uid} Mail: ${user.email}');
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
                          final Future<String> userDetails = getUserData(userId);

                          return InkWell(
                            onTap: () {
                              // Navigate to the ChatPage with the selected user
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    // Pass relevant user information to ChatPage
                                    userId: userId,
                                    userName: data['displayName'] ?? '',
                                  ),
                                ),
                              );
                            },
                            child: FutureBuilder<String>(
                              future: userDetails,
                              builder: (context, userDetailsSnapshot) {
                                if (userDetailsSnapshot.connectionState == ConnectionState.done) {
                                  return ListTile(
                                    title: Text('User ID: $userId, User Details: ${userDetailsSnapshot.data}'),
                                  );
                                } else {
                                  return ListTile(
                                    title: Text('Chargement des details des utilisateurs...'),
                                  );
                                }
                              },
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
