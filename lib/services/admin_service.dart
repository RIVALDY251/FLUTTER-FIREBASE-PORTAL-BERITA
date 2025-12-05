import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cek apakah user adalah admin
  Future<bool> isAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['role'] == 'admin';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Set role user (hanya admin yang bisa)
  Future<void> setUserRole(String userId, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal mengubah role: $e';
    }
  }

  // Get semua users
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get user by ID
  Future<DocumentSnapshot> getUserById(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal memperbarui user: $e';
    }
  }

  // Delete user (dari Firestore, bukan dari Auth)
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw 'Gagal menghapus user: $e';
    }
  }

  // Create user document di Firestore saat registrasi
  Future<void> createUserDocument(
    User user, {
    String? displayName,
    String role = 'user',
  }) async {
    // Retry mechanism - coba 3 kali
    int retries = 3;
    Exception? lastError;

    while (retries > 0) {
      try {
        // Cek apakah document sudah ada
        final docRef = _firestore.collection('users').doc(user.uid);
        final doc = await docRef.get();

        if (doc.exists) {
          // Jika sudah ada, update saja
          await docRef.update({
            'email': user.email,
            'displayName':
                displayName ??
                user.displayName ??
                doc.data()?['displayName'] ??
                '',
            'emailVerified': user.emailVerified,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Jika belum ada, create baru
          await docRef.set({
            'uid': user.uid,
            'email': user.email ?? '',
            'displayName': displayName ?? user.displayName ?? '',
            'role': role,
            'emailVerified': user.emailVerified,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        // Jika berhasil, return
        return;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        retries--;
        if (retries > 0) {
          // Tunggu sebentar sebelum retry
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
    }

    // Jika semua retry gagal, throw error
    throw 'Gagal membuat dokumen user setelah 3 kali percobaan: $lastError. Pastikan Firestore Security Rules mengizinkan user create document sendiri.';
  }

  // Update user document saat user update profil
  Future<void> updateUserDocument(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal memperbarui dokumen user: $e';
    }
  }

  // Get user role
  Future<String> getUserRole(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['role'] ?? 'user';
      }
      return 'user';
    } catch (e) {
      return 'user';
    }
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      final adminCount = usersSnapshot.docs
          .where((doc) => doc.data()['role'] == 'admin')
          .length;
      final userCount = usersSnapshot.docs
          .where((doc) => doc.data()['role'] == 'user')
          .length;
      final verifiedCount = usersSnapshot.docs
          .where((doc) => doc.data()['emailVerified'] == true)
          .length;

      return {
        'totalUsers': totalUsers,
        'adminCount': adminCount,
        'userCount': userCount,
        'verifiedCount': verifiedCount,
      };
    } catch (e) {
      return {
        'totalUsers': 0,
        'adminCount': 0,
        'userCount': 0,
        'verifiedCount': 0,
      };
    }
  }
}
