import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'student_home_page.dart';
import 'teacher_home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F1629),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
            ),
          );
        }

        if (snapshot.hasData) {
          // L'utilisateur est connecté, on vérifie son rôle
          final user = snapshot.data!;
          return FutureBuilder(
            future: Provider.of<AuthService>(context, listen: false).getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF0F1629),
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                  ),
                );
              }

              if (roleSnapshot.hasData && roleSnapshot.data != null) {
                final userModel = roleSnapshot.data!;
                final role = userModel.role;
                if (role == 'teacher') {
                  return TeacherHomePage(user: userModel);
                } else {
                  // Fallback to student for any other role
                  return StudentHomePage(user: userModel);
                }
              }

              // Si le rôle n'est pas trouvé
              return const LoginPage();
            },
          );
        }

        // L'utilisateur n'est pas connecté
        return const LoginPage();
      },
    );
  }
}
