import 'package:cloud_firestore/cloud_firestore.dart';

class KategoriService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _kategoriCollection =>
      _firestore.collection('kategori_berita');

  // Default kategori
  static const List<String> defaultKategori = [
    'Teknologi',
    'Olahraga',
    'Ekonomi',
    'Kesehatan',
    'Pendidikan',
    'Hiburan',
    'Sains',
  ];

  // Initialize default kategori
  Future<void> initializeDefaultKategori() async {
    try {
      for (var kategori in defaultKategori) {
        final docRef = _kategoriCollection.doc(kategori.toLowerCase());
        final doc = await docRef.get();
        
        if (!doc.exists) {
          await docRef.set({
            'nama': kategori,
            'slug': kategori.toLowerCase(),
            'createdAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });
        }
      }
    } catch (e) {
      // Ignore error
    }
  }

  // Get semua kategori
  Stream<QuerySnapshot> getAllKategori() {
    return _kategoriCollection
        .where('isActive', isEqualTo: true)
        .orderBy('nama')
        .snapshots();
  }

  // Get kategori aktif
  Future<List<String>> getKategoriList() async {
    try {
      final snapshot = await _kategoriCollection
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['nama'] as String? ?? '';
          })
          .where((nama) => nama.isNotEmpty)
          .toList();
    } catch (e) {
      return defaultKategori;
    }
  }

  // Tambah kategori
  Future<void> addKategori(String nama) async {
    try {
      final slug = nama.toLowerCase().replaceAll(' ', '-');
      await _kategoriCollection.doc(slug).set({
        'nama': nama,
        'slug': slug,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal menambah kategori: $e';
    }
  }

  // Update kategori
  Future<void> updateKategori(String oldSlug, String nama) async {
    try {
      final newSlug = nama.toLowerCase().replaceAll(' ', '-');
      
      if (oldSlug != newSlug) {
        // Hapus yang lama dan buat yang baru
        await _kategoriCollection.doc(oldSlug).delete();
        await _kategoriCollection.doc(newSlug).set({
          'nama': nama,
          'slug': newSlug,
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update yang sama
        await _kategoriCollection.doc(oldSlug).update({
          'nama': nama,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Gagal memperbarui kategori: $e';
    }
  }

  // Hapus kategori (soft delete)
  Future<void> deleteKategori(String slug) async {
    try {
      await _kategoriCollection.doc(slug).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal menghapus kategori: $e';
    }
  }
}

