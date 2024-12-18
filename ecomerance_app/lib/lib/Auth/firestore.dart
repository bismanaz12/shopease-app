import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentReference> addToCart({
    required String productName,
    required String productImage,
    required String productDescription,
    required String productPrice,
    required int quantity,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      QuerySnapshot<Map<String, dynamic>> query = await _db
          .collection('addtocart')
          .where('userId', isEqualTo: user.uid)
          .where('productName', isEqualTo: productName)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // Product already exists in the cart, update the quantity
        DocumentSnapshot<Map<String, dynamic>> cartItemDoc = query.docs.first;
        int currentQuantity = cartItemDoc['quantity'];

        // Update the existing document by incrementing the quantity
        await cartItemDoc.reference.update({
          'quantity': currentQuantity + quantity,
        });

        return cartItemDoc.reference;
      } else {
        // Product doesn't exist in the cart, create a new entry
        DocumentReference docRef = await _db.collection('addtocart').add({
          'userId': user.uid, // Include user ID
          'productName': productName,
          'productImage': productImage,
          'productDescription': productPrice,
          'productPrice': productDescription,
          'createdAt': Timestamp.now(),
          'quantity':quantity,
        });
        return docRef;

      }
    } catch (e) {
      print('Error adding to cart: $e');
      throw e; // Handle error as per your app's requirement
    }
  }

  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<Map<String, dynamic>?> getUserData() async {
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

  Future<void> addUserToFirestore(
      String userName,
      String email,
      String password,
      ) async {
    try {
      String? userId = getCurrentUserId(); // Get the current user ID

      if (userId == null) {
        throw Exception('No user is currently signed in.');
      }

      await usersCollection.doc(userId).set({
        'imageUrl': '',
        'userName':userName,
        'email': email,
        'uid': userId,
        'password': password,
      });
    } catch (e) {
      print('Error adding user to Firestore: $e');
      throw e; // Rethrow the error to handle it elsewhere if needed
    }
  }
}
