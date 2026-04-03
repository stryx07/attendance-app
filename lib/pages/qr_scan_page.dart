import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'attendance_success_page.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _isScanning = true;
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isScanning = false);

    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    
    final user = authService.currentUser;
    if (user == null) {
      _showError('Utilisateur non connecté.');
      setState(() => _isScanning = true);
      return;
    }

    String subjectId = '';
    String teacherId = '';
    
    try {
      final decoded = jsonDecode(code);
      if (decoded is Map<String, dynamic> && decoded.containsKey('subject') && decoded.containsKey('teacherId')) {
        subjectId = decoded['subject'];
        teacherId = decoded['teacherId'];
        
        final date = decoded['date'];
        final today = DateTime.now().toIso8601String().split('T').first;
        if (date != today) {
          _showError('Ce QR Code n\'est plus valide (date expirée).');
          setState(() => _isScanning = true);
          return;
        }
      } else {
        throw const FormatException('QR non valide');
      }
    } catch (e) {
      _showError('Format du QR Code non valide.');
      setState(() => _isScanning = true);
      return;
    }

    try {
      // Récupération du profil pour avoir le nom de l'étudiant
      final userProfile = await authService.getUserRole(user.uid);
      final studentName = userProfile?.name ?? 'Inconnu';

      final success = await firestoreService.markAttendance(
        subjectId: subjectId,
        teacherId: teacherId,
        studentId: user.uid,
        studentEmail: user.email ?? 'non-specifié',
        studentName: studentName,
      );

      if (!mounted) return;

      if (success) {
        // Nouvelle présence enregistrée → page de succès
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AttendanceSuccessPage(subjectName: subjectId),
          ),
        );
      } else {
        // Doublon détecté
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance already recorded'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isScanning = true);
      }
    } catch (e) {
      _showError('Erreur lors de l\'enregistrement : $e');
      setState(() => _isScanning = true);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scanner le QR Code'),
        backgroundColor: const Color(0xFF1A1F3A),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Overlay de scan
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withAlpha(200), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Alignez le QR Code dans le cadre',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
