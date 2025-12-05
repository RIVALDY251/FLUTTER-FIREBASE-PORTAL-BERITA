import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'admin_service.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminService _adminService = AdminService();

  // Email dan password default untuk admin
  static const String defaultAdminEmail = 'admin@portalberita.com';
  static const String defaultAdminPassword = 'Admin123!';

  // Cek apakah email adalah admin default
  bool isDefaultAdminEmail(String email) {
    return email.toLowerCase() == defaultAdminEmail.toLowerCase();
  }

  // Login khusus admin
  Future<UserCredential?> loginAsAdmin({
    required String email,
    required String password,
  }) async {
    try {
      // Login dengan Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reload user untuk memastikan data ter-update
      await result.user?.reload();

      // Cek apakah user adalah admin
      final isAdmin = await _adminService.isAdmin(result.user!.uid);
      
      if (!isAdmin) {
        // Jika bukan admin, logout dan throw error
        await _auth.signOut();
        throw 'Email atau password salah, atau akun ini bukan admin.';
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // Setup admin default (hanya sekali, saat pertama kali)
  Future<void> setupDefaultAdmin() async {
    try {
      // Cek apakah admin default sudah ada di Firestore
      final adminExists = await _checkAdminExists();
      
      if (adminExists) {
        if (kDebugMode) {
          print('Admin default sudah ada');
        }
        return;
      }

      // Cek apakah user dengan email admin sudah ada di Auth (tanpa login)
      try {
        // Cek di Authentication apakah user sudah ada
        // Kita tidak bisa cek langsung tanpa login, jadi kita coba create dulu
        // Jika sudah ada, akan throw error yang kita handle
        await _createDefaultAdminAccount();
      } catch (e) {
        // Jika error karena email sudah ada, berarti user sudah ada di Auth
        // Tapi belum ada di Firestore dengan role admin
        if (e.toString().contains('email-already-in-use')) {
          // User sudah ada di Auth, tapi belum ada di Firestore
          // Kita perlu login untuk mendapatkan UID, lalu setup role
          try {
            final credential = await _auth.signInWithEmailAndPassword(
              email: defaultAdminEmail,
              password: defaultAdminPassword,
            );
            await _setupAdminRole(credential.user!.uid);
            // Logout setelah setup
            await _auth.signOut();
          } catch (loginError) {
            // Jika login gagal, mungkin password sudah diubah
            // Skip setup, admin bisa dibuat manual
            if (kDebugMode) {
              print('Cannot setup admin: User exists but cannot login. $loginError');
            }
          }
        } else {
          // Error lain, skip
          if (kDebugMode) {
            print('Error setup admin: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setup admin default: $e');
      }
      // Jangan throw error, biarkan aplikasi tetap berjalan
    }
  }

  // Buat akun admin default
  Future<void> _createDefaultAdminAccount() async {
    try {
      // Buat user di Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: defaultAdminEmail,
        password: defaultAdminPassword,
      );

      // Set display name
      await credential.user?.updateDisplayName('Admin Portal');
      await credential.user?.reload();

      // Setup role admin di Firestore
      await _setupAdminRole(credential.user!.uid);
    } catch (e) {
      if (kDebugMode) {
        print('Error create admin account: $e');
      }
      rethrow;
    }
  }

  // Setup role admin di Firestore
  Future<void> _setupAdminRole(String uid) async {
    try {
      await _adminService.createUserDocument(
        _auth.currentUser!,
        displayName: 'Admin Portal',
        role: 'admin',
      );
    } catch (e) {
      // Jika gagal, coba update manual
      try {
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': defaultAdminEmail,
          'displayName': 'Admin Portal',
          'role': 'admin',
          'emailVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e2) {
        if (kDebugMode) {
          print('Error setup admin role: $e2');
        }
      }
    }
  }

  // Cek apakah admin sudah ada
  Future<bool> _checkAdminExists() async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      
      return usersSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Handle Firebase Auth Exception
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'user-not-found':
        return 'Email atau password salah.';
      case 'wrong-password':
        return 'Password salah. Silakan coba lagi.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}

