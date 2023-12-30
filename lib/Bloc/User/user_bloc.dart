import 'dart:async';

import 'package:superchat/Bloc/User/user_repository.dart';

class UserState {
  final String displayName;
  final String bio;

  UserState({required this.displayName, required this.bio});
}

class UserEvent {
  final String userId;

  UserEvent(this.userId);
}

class UserBloc {
  final _userController = StreamController<UserState>.broadcast();
  Stream<UserState> get userStream => _userController.stream;
  final UserRepository _userRepository = UserRepository();

  void getUserData(String userId) async {
    _userRepository.getUserData(userId).listen((userData) {
      _userController.add(UserState(
        displayName: userData['displayName'] ?? "",
        bio: userData['bio'] ?? "",
      ));
    });
  }

  void updateUser({
    required String id,
    required String displayName,
    required String bio,
  }) {
    _userController.add(UserState(displayName: displayName, bio: bio));
    _userRepository.updateProfile(userId: id, displayName: displayName, bio: bio);
  }

  void dispose() {
    _userController.close();
  }

}

final userBloc = UserBloc();
