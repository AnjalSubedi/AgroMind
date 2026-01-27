import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user details
  Future<UserModel?> getCurrentUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  // Sign Up
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String location,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create user doc in Firestore
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          location: location,
          createdAt: DateTime.now().toIso8601String(),
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return null; // Success
      }
      return "User creation failed";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign In
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
