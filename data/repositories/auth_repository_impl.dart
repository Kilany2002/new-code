import 'package:e7gezly/domain/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e7gezly/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      // Map firebaseUser to your custom User entity
      return User(
        id: firebaseUser.uid,
        email: "firebaseUser.email ?? ''", name: '', points: 0.0,
        // Add additional fields as necessary
      );
    } else {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateFcmToken(String userId, String fcmToken) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({"fcmToken": fcmToken});
  }
}
