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

  // Sign In Anonymously
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      if (user != null) {
        // Create Guest User Doc
        await _createOrUpdateUser(
          user,
          "Guest User",
          "Unknown",
          isAnonymous: true,
        );
      }
      return user;
    } catch (e) {
      print("Anonymous Auth Error: $e");
      return null;
    }
  }

  // Verify Phone Number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Sign in with OTP
  Future<String?> signInWithOTP({
    required String verificationId,
    required String smsCode,
    required String name,
    required String location,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        await _createOrUpdateUser(user, name, location);
        return null; // Success
      }
      return "Sign in failed";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Helper to create/update user
  Future<void> _createOrUpdateUser(
    User user,
    String name,
    String location, {
    bool isAnonymous = false,
  }) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      UserModel newUser = UserModel(
        uid: user.uid,
        email:
            user.email ??
            (isAnonymous
                ? "guest@sajilokheti.com"
                : "${user.phoneNumber}@mobile.com"),
        name: name,
        location: location,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
    }
  }

  // Request Verification
  Future<void> requestVerification(
    Map<String, dynamic> additionalDetails,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'verificationRequested': true,
        ...additionalDetails,
      });
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
