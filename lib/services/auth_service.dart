import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Stream<UserModel?> get user {
    return _auth.authStateChanges().map((User? user) {
      if (user != null) {
        return UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoURL: user.photoURL,
          createdAt: DateTime.now(),
        );
      }
      return null;
    });
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user != null
          ? UserModel(
              uid: user.uid,
              email: user.email!,
              displayName: user.displayName,
              photoURL: user.photoURL,
              createdAt: DateTime.now(),
            )
          : null;
    } catch (e) {
      debugPrint('Email sign in error: $e');
      return null;
    }
  }

  Future<UserModel?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user != null
          ? UserModel(
              uid: user.uid,
              email: user.email!,
              displayName: user.displayName,
              photoURL: user.photoURL,
              createdAt: DateTime.now(),
            )
          : null;
    } catch (e) {
      debugPrint('Email sign up error: $e');
      return null;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      return user != null
          ? UserModel(
              uid: user.uid,
              email: user.email!,
              displayName: user.displayName,
              photoURL: user.photoURL,
              createdAt: DateTime.now(),
            )
          : null;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
}
