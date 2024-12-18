import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AdminFirestoreService {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('admin');

  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
  Future<Map<String, dynamic>?> getAdminData() async {
    try {
      String? userId = getCurrentUserId();

      if (userId == null) {
        throw Exception('No user is currently signed in.');
      }

      DocumentSnapshot userSnapshot = await usersCollection.doc(userId).get();

      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('User data not found.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw e; // Rethrow the error to handle it elsewhere if needed
    }
  }
  Future<void> addAdminToFirestore(
      String email,
      String userName,
      String imageUrl,
      String password,

      ) async {
    try {
      String? userId = getCurrentUserId(); // Get the current user ID

      if (userId == null) {
        throw Exception('No user is currently signed in.');
      }

      await usersCollection.doc(userId).set({

        'email': email,
        'uid': userId,
        'password': password,
        'imageUrl': imageUrl,
        'userName':userName

      });
    } catch (e) {
      print('Error adding user to Firestore: $e');
      throw e; // Rethrow the error to handle it elsewhere if needed
    }
  }
}
