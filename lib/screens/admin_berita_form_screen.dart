import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/berita_service.dart';
import '../services/kategori_service.dart';

class AdminBeritaFormScreen extends StatefulWidget {
  final String? beritaId;
  const AdminBeritaFormScreen({super.key, this.beritaId});

  @override
  State<AdminBeritaFormScreen> createState() => _AdminBeritaFormScreenState();
}

class _AdminBeritaFormScreenState extends State<AdminBeritaFormScreen> {
  final BeritaService _beritaService = BeritaService();
  final KategoriService _kategoriService = KategoriService();
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  final _kontenLengkapController = TextEditingController();
  final _penulisController = TextEditingController();

  String? _selectedKategori;
  List<String> _kategoriList = [];
  bool _isPublished = false;
  bool _isLoading = false;
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadKategori();
    if (widget.beritaId != null) {
      await _loadBeritaData();
    } else {
      // Jika tambah baru, set loading ke false setelah kategori di-load
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _loadKategori() async {
    try {
      final kategori = await _kategoriService.getKategoriList();
      setState(() {
        _kategoriList = kategori.isNotEmpty
            ? kategori
            : KategoriService.defaultKategori;
        if (_kategoriList.isNotEmpty && _selectedKategori == null) {
          _selectedKategori = _kategoriList.first;
        }
      });
    } catch (e) {
      setState(() {
        _kategoriList = KategoriService.defaultKategori;
        if (_kategoriList.isNotEmpty) {
          _selectedKategori ??= _kategoriList.first;
        }
      });
    }
  }

  Future<void> _loadBeritaData() async {
    try {
      final doc = await _beritaService.getBeritaById(widget.beritaId!);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _judulController.text = data['judul'] ?? '';
          _isiController.text = data['isi'] ?? '';
          _kontenLengkapController.text = data['kontenLengkap'] ?? '';
          _penulisController.text = data['penulis'] ?? '';
          _selectedKategori = data['kategori'] ?? _kategoriList.first;
          _isPublished = data['isPublished'] ?? false;
          _existingImageUrl = data['imageUrl'] as String?;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    } finally {
      // Pastikan loading selalu di-set ke false setelah selesai
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _existingImageUrl =
              null; // Clear existing URL when new image is picked
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
      }
    }
  }

  Future<void> _saveBerita() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.beritaId == null) {
        // Tambah baru
        await _beritaService.addBerita(
          judul: _judulController.text.trim(),
          kategori: _selectedKategori!,
          isi: _isiController.text.trim(),
          kontenLengkap: _kontenLengkapController.text.trim(),
          penulis: _penulisController.text.trim().isEmpty
              ? null
              : _penulisController.text.trim(),
          imageFile: _imageFile,
          isPublished: _isPublished,
        );
      } else {
        // Update
        await _beritaService.updateBerita(
          id: widget.beritaId!,
          judul: _judulController.text.trim(),
          kategori: _selectedKategori!,
          isi: _isiController.text.trim(),
          kontenLengkap: _kontenLengkapController.text.trim(),
          penulis: _penulisController.text.trim().isEmpty
              ? null
              : _penulisController.text.trim(),
          imageUrl: _existingImageUrl,
          imageFile: _imageFile,
          isPublished: _isPublished,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.beritaId == null
                  ? 'Berita berhasil ditambahkan'
                  : 'Berita berhasil diperbarui',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    _kontenLengkapController.dispose();
    _penulisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.beritaId == null ? 'Tambah Berita' : 'Edit Berita',
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.beritaId == null ? 'Tambah Berita' : 'Edit Berita'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveBerita,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview
              if (_imageFile != null || _existingImageUrl != null)
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : _existingImageUrl != null
                        ? Image.network(
                            _existingImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 64),
                              );
                            },
                          )
                        : null,
                  ),
                ),

              // Image Picker Button
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: Text(
                  _imageFile != null || _existingImageUrl != null
                      ? 'Ganti Gambar'
                      : 'Pilih Gambar',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Judul
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Berita *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                initialValue: _selectedKategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
                  border: OutlineInputBorder(),
                ),
                items: _kategoriList.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedKategori = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih kategori';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Penulis
              TextFormField(
                controller: _penulisController,
                decoration: const InputDecoration(
                  labelText: 'Penulis',
                  hintText: 'Kosongkan untuk menggunakan nama admin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Isi (Ringkasan)
              TextFormField(
                controller: _isiController,
                decoration: const InputDecoration(
                  labelText: 'Isi Ringkasan *',
                  hintText: 'Ringkasan singkat berita',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Isi ringkasan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Konten Lengkap
              TextFormField(
                controller: _kontenLengkapController,
                decoration: const InputDecoration(
                  labelText: 'Konten Lengkap *',
                  hintText: 'Isi berita lengkap',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Konten lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Published Switch
              Card(
                child: SwitchListTile(
                  title: const Text('Publish Berita'),
                  subtitle: Text(
                    _isPublished
                        ? 'Berita akan langsung terlihat oleh users'
                        : 'Berita disimpan sebagai draft',
                  ),
                  value: _isPublished,
                  onChanged: (value) {
                    setState(() => _isPublished = value);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveBerita,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Berita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
