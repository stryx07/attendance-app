import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // --- LOGIN ---
  // Returns null on success, or an error message string on failure.
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Aucun utilisateur trouvé pour cet email.';
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'invalid-email':
          return 'Adresse email invalide.';
        case 'invalid-credential':
          return 'Email ou mot de passe incorrect.';
        default:
          return 'Erreur : ${e.message}';
      }
    }
  }

  // --- REGISTER ---
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Une erreur est survenue.';
    }
  }

  // --- GET USER ROLE FROM FIRESTORE ---
  // Returns the UserModel or null if not found in the 'users' collection.
  Future<UserModel?> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
  }
}
