import 'package:firebase_auth/firebase_auth.dart';

/// Utility class untuk menangani error di seluruh aplikasi
class ErrorHandler {
  /// Handle Firebase Auth Exception
  /// Mengubah error code menjadi pesan yang user-friendly dalam bahasa Indonesia
  static String handleAuthException(FirebaseAuthException e) {
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
      
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa koneksi Anda.';
      
      case 'invalid-credential':
        return 'Email atau password salah.';
      
      default:
        return 'Terjadi kesalahan: ${e.message ?? e.code}';
    }
  }

  /// Handle Firestore Exception
  static String handleFirestoreException(dynamic e) {
    final errorString = e.toString().toLowerCase();
    
    if (errorString.contains('permission-denied')) {
      return 'Akses ditolak. Pastikan Anda sudah login dan memiliki izin yang cukup.';
    }
    
    if (errorString.contains('not-found')) {
      return 'Data tidak ditemukan.';
    }
    
    if (errorString.contains('already-exists')) {
      return 'Data sudah ada.';
    }
    
    if (errorString.contains('failed-precondition')) {
      return 'Operasi tidak dapat dilakukan. Periksa kondisi data.';
    }
    
    if (errorString.contains('unavailable')) {
      return 'Layanan tidak tersedia. Silakan coba lagi nanti.';
    }
    
    return 'Terjadi kesalahan saat mengakses database: $e';
  }

  /// Handle Storage Exception
  static String handleStorageException(dynamic e) {
    final errorString = e.toString().toLowerCase();
    
    if (errorString.contains('unauthorized')) {
      return 'Akses ditolak. Pastikan Anda memiliki izin untuk upload file.';
    }
    
    if (errorString.contains('object-not-found')) {
      return 'File tidak ditemukan.';
    }
    
    if (errorString.contains('quota-exceeded')) {
      return 'Kuota storage telah habis.';
    }
    
    if (errorString.contains('unauthenticated')) {
      return 'Anda harus login untuk mengupload file.';
    }
    
    return 'Gagal mengupload file: $e';
  }

  /// Handle Generic Exception
  static String handleGenericException(dynamic e) {
    if (e is FirebaseAuthException) {
      return handleAuthException(e);
    }
    
    if (e.toString().contains('firestore') || 
        e.toString().contains('cloud_firestore')) {
      return handleFirestoreException(e);
    }
    
    if (e.toString().contains('storage') || 
        e.toString().contains('firebase_storage')) {
      return handleStorageException(e);
    }
    
    return 'Terjadi kesalahan: $e';
  }
}

