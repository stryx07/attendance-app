import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── UTILS ──────────────────────────────────────────────────────────────────
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      debugPrint('Error creating user profile: $e');
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
    }
    return null;
  }

  // ─── ATTENDANCE ─────────────────────────────────────────────────────────────
  /// Returns `true` if attendance was saved, `false` if already recorded.
  Future<bool> markAttendance({
    required String subjectId,
    required String studentId,
    required String studentEmail,
  }) async {
    try {
      // Stratégie anti-doublon: subjectId_studentId_YYYYMMDD
      final today = DateTime.now();
      final dateKey = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      final docId = '${subjectId}_${studentId}_$dateKey';

      // Vérifier si la présence existe déjà
      final existing = await _db.collection('attendance').doc(docId).get();
      if (existing.exists) {
        return false; // Déjà enregistré
      }

      await _db.collection('attendance').doc(docId).set({
        'subjectId': subjectId,
        'studentId': studentId,
        'studentEmail': studentEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true; // Nouvelle présence enregistrée
    } catch (e) {
      debugPrint('Error marking attendance: $e');
      return false;
    }
  }
}
