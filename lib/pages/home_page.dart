import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superchat/constants.dart';
import 'package:superchat/pages/sign_in_page.dart';
import 'package:superchat/widgets/stream_listener.dart';

import '../Bloc/Message/chat_page.dart';
import '../Bloc/User/user_page.dart';
import '../Bloc/User/user_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserRepository userRepository = UserRepository();
  late String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userData = await userRepository.getUserData(userId).first;
    setState(() {
      userName = userData['displayName'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserPage(),
                  ),
                );
              },
            ),
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
              height: 50,
              child: Center(
                child: StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      final User? user = snapshot.data;
                      if (user != null) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Bienvenue, $userName'),
                          ],
                        );
                      } else {
                        return const Text('User not logged in');
                      }
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
            ),
            Expanded(
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
                          final String userName = data['displayName'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Card(
                              elevation: 2.0,
                              child: InkWell(
                                onTap: () {
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
                                  leading: Icon(Icons.person),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return ListTile(
                            title: const Text('Error retrieving user data'),
                          );
                        }
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
