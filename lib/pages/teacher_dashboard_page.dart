import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';

class TeacherDashboardPage extends StatelessWidget {
  final UserModel teacher;
  
  const TeacherDashboardPage({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1629),
      appBar: AppBar(
        title: Text(
          'Mon Tableau de bord',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1A1F3A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('teacherId', isEqualTo: teacher.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erreur de chargement des statistiques',
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          
          int totalAttendances = docs.length;
          Set<String> uniqueStudents = {};
          Set<String> uniqueSubjects = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final studentId = data['studentId'] as String?;
            final subjectId = data['subjectId'] as String?;
            
            if (studentId != null) uniqueStudents.add(studentId);
            if (subjectId != null) uniqueSubjects.add(subjectId);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vue d\'ensemble',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(
                      title: 'Présences',
                      value: totalAttendances.toString(),
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF00BCD4),
                    ),
                    _buildStatCard(
                      title: 'Étudiants uniques',
                      value: uniqueStudents.length.toString(),
                      icon: Icons.people_alt_rounded,
                      color: const Color(0xFF7C4DFF),
                    ),
                    _buildStatCard(
                      title: 'Matières enseignées',
                      value: uniqueSubjects.length.toString(),
                      icon: Icons.book_rounded,
                      color: const Color(0xFFFF9800),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
