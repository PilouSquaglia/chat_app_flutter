import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:superchat/Bloc/User/user_repository.dart';
import 'user_bloc.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late UserBloc userBloc;
  final UserRepository userRepository = UserRepository();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userBloc = UserBloc();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    var userData = await userRepository.getUserData(userId).first;

    setState(() {
      displayNameController.text = userData['displayName'] ?? '';
      emailController.text = userData['email'] ?? '';
      bioController.text = userData['bio'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Utilisateur'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom d\'affichage:'),
            TextField(
              controller: displayNameController,
            ),
            SizedBox(height: 16),
            Text('Bio:'),
            TextField(
              controller: bioController,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _updateProfile();
              },
              child: Text('Enregistrer les modifications'),
            ),
          ],
        ),
      ),
    );
  }

  _updateProfile() {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    String displayName = displayNameController.text.trim();
    String bio = bioController.text.trim();

    userBloc.updateUser(
      id: userId,
      displayName: displayName,
      bio: bio,
    );
  }

  @override
  void dispose() {
    super.dispose();
    userBloc.dispose();
  }
}
