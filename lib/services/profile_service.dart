import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get profile data dari Firestore
  Future<Map<String, dynamic>?> getProfileData() async {
    if (currentUserId == null) return null;

    try {
      final doc = await _firestore
          .collection('user_profiles')
          .doc(currentUserId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw 'Gagal mengambil data profil: $e';
    }
  }

  // Create atau Update profile data
  Future<void> saveProfileData({
    String? alamat,
    String? telepon,
  }) async {
    if (currentUserId == null) {
      throw 'User tidak ditemukan';
    }

    try {
      final profileData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (alamat != null) {
        profileData['alamat'] = alamat.trim();
      }
      if (telepon != null) {
        profileData['telepon'] = telepon.trim();
      }

      // Cek apakah document sudah ada
      final docRef = _firestore.collection('user_profiles').doc(currentUserId);
      final doc = await docRef.get();

      if (doc.exists) {
        // Update existing document
        await docRef.update(profileData);
      } else {
        // Create new document
        profileData['createdAt'] = FieldValue.serverTimestamp();
        profileData['userId'] = currentUserId;
        await docRef.set(profileData);
      }
    } catch (e) {
      throw 'Gagal menyimpan data profil: $e';
    }
  }

  // Delete profile data
  Future<void> deleteProfileData() async {
    if (currentUserId == null) {
      throw 'User tidak ditemukan';
    }

    try {
      await _firestore
          .collection('user_profiles')
          .doc(currentUserId)
          .delete();
    } catch (e) {
      throw 'Gagal menghapus data profil: $e';
    }
  }

  // Stream untuk real-time updates
  Stream<DocumentSnapshot> getProfileStream() {
    if (currentUserId == null) {
      throw 'User tidak ditemukan';
    }

    return _firestore
        .collection('user_profiles')
        .doc(currentUserId)
        .snapshots();
  }
}

