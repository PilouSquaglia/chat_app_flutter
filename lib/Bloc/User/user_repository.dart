import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<Map<String, dynamic>> getUserData(String userId) {
    return _firestore
        .collection('users')
        .where('id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        print(snapshot.docs.first.data());
        return snapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    });
  }


  Future<void> updateProfile({
    required String userId,
    required String displayName,
    required String bio,
  }) async {
    try {
      print(userId);
      await _auth.currentUser?.updateDisplayName(displayName);

      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('id', isEqualTo: userId)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        for (var doc in userSnapshot.docs) {
          await doc.reference.update({
            'displayName': displayName,
            'bio': bio,
          });
        }
      } else {
        print('Aucun document trouvé pour la mise à jour.');
      }
    } catch (e) {
      print("Erreur lors de la mise à jour du profil: $e");
    }
  }

}
