import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'admin_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AdminService _adminService = AdminService();

  // Stream untuk mendengarkan perubahan status auth
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Register dengan email dan password
  Future<UserCredential?> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name jika ada
      if (displayName != null && displayName.isNotEmpty) {
        try {
          await result.user?.updateDisplayName(displayName);
        } catch (e) {
          // Ignore error jika update display name gagal
          if (kDebugMode) {
            print('Warning: Gagal update display name: $e');
          }
        }
      }

      // Buat dokumen user di Firestore untuk admin management
      try {
        await _adminService.createUserDocument(
          result.user!,
          displayName: displayName,
          role: 'user',
        );
        if (kDebugMode) {
          print('✓ User document berhasil dibuat di Firestore');
        }
      } catch (e) {
        // Log error dengan detail
        if (kDebugMode) {
          print('⚠️ Warning: Gagal membuat dokumen user di Firestore: $e');
          print(
            '⚠️ User sudah terdaftar di Firebase Auth, tapi tidak ada di Firestore',
          );
          print(
            '⚠️ Pastikan Firestore Security Rules mengizinkan user create document sendiri',
          );
        }
        // Jangan throw error, biarkan user tetap bisa login
        // Admin bisa melihat user di Firebase Auth, tapi tidak di Firestore
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  // Cek apakah user adalah admin
  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    return await _adminService.isAdmin(currentUser!.uid);
  }

  // Login dengan email dan password
  Future<UserCredential?> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reload user untuk memastikan data ter-update
      await result.user?.reload();

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  // Update password
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User tidak ditemukan';
      }

      // Re-authenticate user dengan password lama
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Gagal logout: $e';
    }
  }

  // Handle Firebase Auth Exception
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan gunakan email lain.';
      case 'user-not-found':
        return 'Email tidak ditemukan. Silakan daftar terlebih dahulu.';
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
      case 'requires-recent-login':
        return 'Untuk keamanan, silakan login ulang sebelum mengubah password.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
