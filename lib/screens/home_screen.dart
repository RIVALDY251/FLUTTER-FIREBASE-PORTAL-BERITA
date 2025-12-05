import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/berita_service.dart';
import 'berita_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final BeritaService _beritaService = BeritaService();
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  // Dummy data berita untuk ditampilkan di home (fallback)
  final List<Map<String, dynamic>> _dummyFeaturedNews = [
    {
      'judul': 'ChatGPT-5 Diresmikan: Revolusi AI Generasi Berikutnya',
      'kategori': 'Teknologi',
      'tanggal': '15 Desember 2024',
      'penulis': 'Tech Reporter',
      'isi':
          'OpenAI resmi meluncurkan ChatGPT-5 dengan kemampuan reasoning yang jauh lebih canggih.',
    },
    {
      'judul': 'Indonesia Juara Umum SEA Games 2024',
      'kategori': 'Olahraga',
      'tanggal': '13 Desember 2024',
      'penulis': 'Sport News',
      'isi':
          'Tim Indonesia berhasil meraih juara umum SEA Games dengan total 156 medali emas.',
    },
    {
      'judul': 'Inflasi Global Turun ke Level Terendah dalam 2 Tahun',
      'kategori': 'Ekonomi',
      'tanggal': '14 Desember 2024',
      'penulis': 'Ekonomi Daily',
      'isi': 'Bank Sentral dunia melaporkan penurunan inflasi yang signifikan.',
    },
  ];

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final displayName =
        user?.displayName ?? user?.email?.split('@')[0] ?? 'Pengguna';
    final timeOfDay = DateTime.now().hour;
    String greeting = 'Selamat pagi';
    if (timeOfDay >= 12 && timeOfDay < 15) {
      greeting = 'Selamat siang';
    } else if (timeOfDay >= 15 && timeOfDay < 19) {
      greeting = 'Selamat sore';
    } else if (timeOfDay >= 19 || timeOfDay < 5) {
      greeting = 'Selamat malam';
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar compact dengan gradient
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: true,
              elevation: 2,
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: Row(
                children: [
                  Icon(Icons.article, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Portal Berita',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    } else if (value == 'about') {
                      _showAboutDialog(context);
                    } else if (value == 'logout') {
                      _showLogoutDialog(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 20),
                          SizedBox(width: 8),
                          Text('Profil'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'about',
                      child: Row(
                        children: [
                          Icon(Icons.info, size: 20),
                          SizedBox(width: 8),
                          Text('Tentang'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Keluar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section dengan Card yang lebih menarik dan responsif
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width > 600 ? 40 : 20,
                      12,
                      MediaQuery.of(context).size.width > 600 ? 40 : 20,
                      8,
                    ),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(
                                context,
                                // ignore: deprecated_member_use
                              ).colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                        ),
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width > 600 ? 20 : 16,
                        ),
                        child: Row(
                          children: [
                            // Avatar dengan border - responsif
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: MediaQuery.of(context).size.width > 600
                                    ? 36
                                    : 32,
                                backgroundColor: Colors.white,
                                child: Text(
                                  displayName[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width > 600
                                        ? 28
                                        : 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width > 600
                                  ? 20
                                  : 16,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    greeting,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize:
                                          MediaQuery.of(context).size.width >
                                              600
                                          ? 16
                                          : 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width >
                                              600
                                          ? 24
                                          : 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Selamat membaca berita terkini',
                                    style: TextStyle(
                                      // ignore: deprecated_member_use
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize:
                                          MediaQuery.of(context).size.width >
                                              600
                                          ? 14
                                          : 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Icon dekoratif - hanya muncul di layar besar
                            if (MediaQuery.of(context).size.width > 400)
                              Icon(
                                Icons.waving_hand,
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.8),
                                size: MediaQuery.of(context).size.width > 600
                                    ? 28
                                    : 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Quick Categories
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width > 600
                          ? 40
                          : 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kategori',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildCategoryChip('Semua', Colors.blue, true),
                              const SizedBox(width: 8),
                              _buildCategoryChip(
                                'Teknologi',
                                Colors.blue,
                                false,
                              ),
                              const SizedBox(width: 8),
                              _buildCategoryChip(
                                'Olahraga',
                                Colors.orange,
                                false,
                              ),
                              const SizedBox(width: 8),
                              _buildCategoryChip(
                                'Ekonomi',
                                Colors.green,
                                false,
                              ),
                              const SizedBox(width: 8),
                              _buildCategoryChip(
                                'Kesehatan',
                                Colors.red,
                                false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Featured News Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width > 600
                          ? 40
                          : 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Berita Terbaru',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BeritaListScreen(),
                              ),
                            );
                          },
                          child: const Text('Lihat Semua'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // News List from Firestore
                  StreamBuilder(
                    stream: _beritaService.getPublishedBerita(limit: 3),
                    builder: (context, snapshot) {
                      List<Map<String, dynamic>> featuredNews = [];

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        featuredNews = snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>?;
                          return {
                            'id': doc.id,
                            'judul': data?['judul'] ?? '',
                            'kategori': data?['kategori'] ?? 'Lainnya',
                            'isi': data?['isi'] ?? '',
                            'penulis': data?['penulis'] ?? 'Admin',
                            'imageUrl': data?['imageUrl'] as String?,
                            'tanggal': _formatTimestamp(data?['createdAt']),
                          };
                        }).toList();
                      } else {
                        // Fallback ke dummy data
                        featuredNews = _dummyFeaturedNews;
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width > 600
                              ? 40
                              : 20,
                        ),
                        itemCount: featuredNews.length,
                        itemBuilder: (context, index) {
                          final news = featuredNews[index];
                          final categoryColor = _getCategoryColor(
                            news['kategori'],
                          );
                          return _buildNewsCard(context, news, categoryColor);
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BeritaListScreen()),
            );
            setState(() => _selectedIndex = 0);
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            setState(() => _selectedIndex = 0);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Berita'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.article, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Tentang Aplikasi'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portal Berita',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Aplikasi Portal Berita adalah aplikasi berita modern dengan Firebase Authentication. '
              'Aplikasi ini menyediakan berbagai berita terkini dari berbagai kategori seperti teknologi, '
              'olahraga, ekonomi, kesehatan, dan pendidikan.',
            ),
            SizedBox(height: 16),
            Text('Fitur:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Autentikasi dengan Firebase'),
            Text('• Berita terkini dari berbagai kategori'),
            Text('• Profil pengguna yang dapat disesuaikan'),
            Text('• Tampilan responsif dan modern'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Konfirmasi Keluar'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await _authService.logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Widget _buildCategoryChip(String label, Color color, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      // ignore: deprecated_member_use
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Baru saja';

    try {
      final date = timestamp.toDate() as DateTime;
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Baru saja';
          }
          return '${difference.inMinutes} menit yang lalu';
        }
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Baru saja';
    }
  }

  Widget _buildNewsCard(
    BuildContext context,
    Map<String, dynamic> news,
    Color categoryColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BeritaListScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (news['imageUrl'] != null &&
                news['imageUrl'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  news['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 48),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            // ignore: deprecated_member_use
                            color: categoryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          news['kategori'],
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (news['tanggal'] != null)
                        Text(
                          news['tanggal'],
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    news['judul'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news['isi'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        news['penulis'] ?? 'Admin',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Baca selengkapnya',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
