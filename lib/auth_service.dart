import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      throw 'Passwords do not match';
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to sign up';
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to sign in';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  // Optional: reset to system locale
  void clearLocale() {
    _locale = const Locale('en');
    notifyListeners();
  }
}
