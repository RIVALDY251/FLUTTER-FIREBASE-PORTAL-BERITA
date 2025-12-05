import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class BeritaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _beritaCollection =>
      _firestore.collection('berita');

  // Get semua berita
  Stream<QuerySnapshot> getAllBerita() {
    return _beritaCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get berita by ID
  Future<DocumentSnapshot> getBeritaById(String id) async {
    return await _beritaCollection.doc(id).get();
  }

  // Get berita published
  Stream<QuerySnapshot> getPublishedBerita({int? limit}) {
    var query = _beritaCollection
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true);
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return query.snapshots();
  }

  // Get berita by kategori
  Stream<QuerySnapshot> getBeritaByKategori(String kategori) {
    return _beritaCollection
        .where('kategori', isEqualTo: kategori)
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Tambah berita
  Future<String> addBerita({
    required String judul,
    required String kategori,
    required String isi,
    required String kontenLengkap,
    String? penulis,
    String? imageUrl,
    File? imageFile,
    bool isPublished = false,
  }) async {
    try {
      String? finalImageUrl = imageUrl;

      // Upload gambar jika ada
      if (imageFile != null) {
        finalImageUrl = await _uploadImage(imageFile);
      }

      final user = _auth.currentUser;
      final docRef = _beritaCollection.doc();

      await docRef.set({
        'id': docRef.id,
        'judul': judul,
        'kategori': kategori,
        'isi': isi,
        'kontenLengkap': kontenLengkap,
        'penulis': penulis ?? user?.displayName ?? 'Admin',
        'imageUrl': finalImageUrl,
        'isPublished': isPublished,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': user?.uid,
        'views': 0,
      });

      return docRef.id;
    } catch (e) {
      throw 'Gagal menambah berita: $e';
    }
  }

  // Update berita
  Future<void> updateBerita({
    required String id,
    required String judul,
    required String kategori,
    required String isi,
    required String kontenLengkap,
    String? penulis,
    String? imageUrl,
    File? imageFile,
    bool? isPublished,
  }) async {
    try {
      String? finalImageUrl = imageUrl;

      // Upload gambar baru jika ada
      if (imageFile != null) {
        finalImageUrl = await _uploadImage(imageFile);
      }

      final updateData = <String, dynamic>{
        'judul': judul,
        'kategori': kategori,
        'isi': isi,
        'kontenLengkap': kontenLengkap,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (penulis != null) {
        updateData['penulis'] = penulis;
      }
      if (finalImageUrl != null) {
        updateData['imageUrl'] = finalImageUrl;
      }
      if (isPublished != null) {
        updateData['isPublished'] = isPublished;
      }

      await _beritaCollection.doc(id).update(updateData);
    } catch (e) {
      throw 'Gagal memperbarui berita: $e';
    }
  }

  // Hapus berita
  Future<void> deleteBerita(String id) async {
    try {
      // Hapus gambar jika ada
      final doc = await _beritaCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final imageUrl = data?['imageUrl'] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          try {
            await _storage.refFromURL(imageUrl).delete();
          } catch (e) {
            // Ignore error jika gambar tidak ditemukan
          }
        }
      }

      await _beritaCollection.doc(id).delete();
    } catch (e) {
      throw 'Gagal menghapus berita: $e';
    }
  }

  // Publish/Unpublish berita
  Future<void> togglePublishBerita(String id, bool isPublished) async {
    try {
      await _beritaCollection.doc(id).update({
        'isPublished': isPublished,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal mengubah status publikasi: $e';
    }
  }

  // Upload gambar
  Future<String> _uploadImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      final fileName =
          'berita_${DateTime.now().millisecondsSinceEpoch}_${user?.uid ?? 'anonymous'}.jpg';
      final ref = _storage.ref().child('berita_images').child(fileName);

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Gagal upload gambar: $e';
    }
  }

  // Increment views
  Future<void> incrementViews(String id) async {
    try {
      await _beritaCollection.doc(id).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      // Ignore error
    }
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final allBerita = await _beritaCollection.get();
      final publishedBerita = allBerita.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['isPublished'] == true;
          })
          .length;
      final draftBerita = allBerita.docs.length - publishedBerita;

      // Group by kategori
      final kategoriMap = <String, int>{};
      for (var doc in allBerita.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        final kategori = data?['kategori'] as String? ?? 'Lainnya';
        kategoriMap[kategori] = (kategoriMap[kategori] ?? 0) + 1;
      }

      return {
        'totalBerita': allBerita.docs.length,
        'publishedBerita': publishedBerita,
        'draftBerita': draftBerita,
        'kategoriStats': kategoriMap,
      };
    } catch (e) {
      return {
        'totalBerita': 0,
        'publishedBerita': 0,
        'draftBerita': 0,
        'kategoriStats': <String, int>{},
      };
    }
  }
}

