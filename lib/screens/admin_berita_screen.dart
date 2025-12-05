import 'package:flutter/material.dart';
import '../services/berita_service.dart';
import 'admin_berita_form_screen.dart';

class AdminBeritaScreen extends StatefulWidget {
  const AdminBeritaScreen({super.key});

  @override
  State<AdminBeritaScreen> createState() => _AdminBeritaScreenState();
}

class _AdminBeritaScreenState extends State<AdminBeritaScreen> {
  final BeritaService _beritaService = BeritaService();
  String _filterStatus = 'all'; // all, published, draft

  Color _getCategoryColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'teknologi':
        return Colors.blue;
      case 'ekonomi':
        return Colors.green;
      case 'olahraga':
        return Colors.orange;
      case 'kesehatan':
        return Colors.red;
      case 'pendidikan':
        return Colors.purple;
      case 'hiburan':
        return Colors.pink;
      case 'sains':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Action buttons moved to top
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminBeritaFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Berita'),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'all',
                      child: Text('Semua Berita'),
                    ),
                    const PopupMenuItem(
                      value: 'published',
                      child: Text('Published'),
                    ),
                    const PopupMenuItem(value: 'draft', child: Text('Draft')),
                  ],
                  child: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _beritaService.getAllBerita(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada berita',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final beritaList = snapshot.data!.docs.where((doc) {
                  if (_filterStatus == 'all') return true;
                  final data = doc.data() as Map<String, dynamic>;
                  final isPublished = data['isPublished'] ?? false;
                  if (_filterStatus == 'published') return isPublished;
                  if (_filterStatus == 'draft') return !isPublished;
                  return true;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: beritaList.length,
                  itemBuilder: (context, index) {
                    final doc = beritaList[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final id = doc.id;
                    final judul = data['judul'] ?? 'Tanpa Judul';
                    final kategori = data['kategori'] ?? 'Lainnya';
                    final isPublished = data['isPublished'] ?? false;
                    final imageUrl = data['imageUrl'] as String?;
                    final views = data['views'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: _getCategoryColor(
                                    kategori,
                                  // ignore: deprecated_member_use
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.article,
                                  color: _getCategoryColor(kategori),
                                ),
                              ),
                        title: Text(
                          judul,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: _getCategoryColor(
                                      kategori,
                                    // ignore: deprecated_member_use
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    kategori,
                                    style: TextStyle(
                                      color: _getCategoryColor(kategori),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPublished
                                        // ignore: deprecated_member_use
                                        ? Colors.green.withOpacity(0.1)
                                        // ignore: deprecated_member_use
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isPublished ? 'Published' : 'Draft',
                                    style: TextStyle(
                                      color: isPublished
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.visibility,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$views',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdminBeritaFormScreen(beritaId: id),
                                ),
                              );
                            } else if (value == 'toggle') {
                              await _beritaService.togglePublishBerita(
                                id,
                                !isPublished,
                              );
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isPublished
                                          ? 'Berita di-unpublish'
                                          : 'Berita di-publish',
                                    ),
                                  ),
                                );
                              }
                            } else if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Berita'),
                                  content: const Text(
                                    'Apakah Anda yakin ingin menghapus berita ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && mounted) {
                                try {
                                  await _beritaService.deleteBerita(id);
                                  if (mounted) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Berita berhasil dihapus',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Gagal menghapus: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(
                                    isPublished
                                        ? Icons.visibility_off
                                        : Icons.publish,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(isPublished ? 'Unpublish' : 'Publish'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
