import 'package:flutter/material.dart';
import '../services/berita_service.dart';

class BeritaListScreen extends StatelessWidget {
  BeritaListScreen({super.key});

  final BeritaService _beritaService = BeritaService();

  // Dummy data berita dengan konten lengkap (fallback jika Firestore kosong)
  final List<Map<String, dynamic>> _dummyBeritaList = [
    {
      'judul': 'ChatGPT-5 Diresmikan: Revolusi AI Generasi Berikutnya',
      'kategori': 'Teknologi',
      'tanggal': '15 Desember 2024',
      'penulis': 'Tech Reporter',
      'isi':
          'OpenAI resmi meluncurkan ChatGPT-5 dengan kemampuan reasoning yang jauh lebih canggih. Model terbaru ini mampu memahami konteks lebih dalam dan memberikan solusi yang lebih akurat untuk berbagai masalah kompleks.',
      'konten_lengkap':
          'OpenAI telah mengumumkan peluncuran ChatGPT-5, model AI generasi terbaru yang membawa revolusi dalam teknologi percakapan. Model ini diklaim memiliki kemampuan reasoning yang 10x lebih baik dibandingkan pendahulunya.\n\nChatGPT-5 dilengkapi dengan kemampuan multimodal yang memungkinkannya memahami tidak hanya teks, tetapi juga gambar, video, dan audio secara bersamaan. Hal ini membuka peluang baru dalam berbagai bidang seperti pendidikan, kesehatan, dan bisnis.\n\n"ChatGPT-5 mewakili lompatan besar dalam teknologi AI," kata CEO OpenAI dalam konferensi pers. "Kami percaya ini akan mengubah cara manusia berinteraksi dengan teknologi."\n\nPara ahli teknologi memprediksi bahwa ChatGPT-5 akan digunakan secara luas dalam pengembangan aplikasi cerdas, asisten virtual yang lebih pintar, dan sistem otomasi yang lebih efisien.',
    },
    {
      'judul': 'Inflasi Global Turun ke Level Terendah dalam 2 Tahun',
      'kategori': 'Ekonomi',
      'tanggal': '14 Desember 2024',
      'penulis': 'Ekonomi Daily',
      'isi':
          'Bank Sentral dunia melaporkan penurunan inflasi yang signifikan. Indikator ekonomi menunjukkan pemulihan yang stabil setelah periode ketidakpastian global.',
      'konten_lengkap':
          'Data terbaru menunjukkan inflasi global turun ke level 2.8%, angka terendah dalam dua tahun terakhir. Penurunan ini didorong oleh stabilisasi harga energi dan pangan di pasar internasional.\n\nBank Sentral berbagai negara menyambut positif tren ini. "Kami melihat tanda-tanda pemulihan ekonomi yang stabil," kata Gubernur Bank Sentral dalam pernyataan resmi.\n\nSektor manufaktur dan jasa menunjukkan pertumbuhan positif, dengan lapangan kerja yang terus meningkat. Para analis memprediksi ekonomi global akan tumbuh 3.2% pada tahun depan.\n\nMeskipun demikian, para ahli tetap mengingatkan perlunya kewaspadaan terhadap gejolak geopolitik yang masih berpotensi mempengaruhi stabilitas ekonomi.',
    },
    {
      'judul': 'Indonesia Juara Umum SEA Games 2024',
      'kategori': 'Olahraga',
      'tanggal': '13 Desember 2024',
      'penulis': 'Sport News',
      'isi':
          'Tim Indonesia berhasil meraih juara umum SEA Games dengan total 156 medali emas. Prestasi ini menjadi yang terbaik dalam sejarah partisipasi Indonesia di ajang regional.',
      'konten_lengkap':
          'Indonesia menorehkan sejarah baru dengan menjadi juara umum SEA Games 2024. Dengan total 156 medali emas, 98 perak, dan 87 perunggu, Indonesia berhasil mengungguli Thailand yang berada di posisi kedua.\n\nCabang olahraga yang memberikan kontribusi terbesar antara lain bulutangkis dengan 7 emas, renang dengan 12 emas, dan atletik dengan 15 emas. "Ini adalah prestasi luar biasa bagi bangsa Indonesia," kata Menteri Pemuda dan Olahraga.\n\nPara atlet mengungkapkan kebahagiaan mereka atas pencapaian ini. "Kami berlatih keras selama bertahun-tahun untuk momen ini," kata salah satu atlet peraih emas.\n\nPrestasi ini diharapkan dapat memotivasi generasi muda untuk terus berprestasi di bidang olahraga dan membawa nama Indonesia di kancah internasional.',
    },
    {
      'judul': 'WHO: Vaksin Flu Universal Berhasil Uji Klinis Fase 3',
      'kategori': 'Kesehatan',
      'tanggal': '12 Desember 2024',
      'penulis': 'Health Journal',
      'isi':
          'Organisasi Kesehatan Dunia mengumumkan keberhasilan uji klinis vaksin flu universal. Vaksin ini diharapkan dapat memberikan perlindungan jangka panjang terhadap berbagai strain virus influenza.',
      'konten_lengkap':
          'Setelah bertahun-tahun penelitian, para ilmuwan akhirnya berhasil mengembangkan vaksin flu universal yang efektif melawan berbagai strain virus influenza. Uji klinis fase 3 menunjukkan tingkat efektivitas mencapai 85%.\n\n"Vaksin ini merupakan terobosan besar dalam dunia medis," kata Direktur WHO. "Kami berharap ini dapat mengurangi beban penyakit flu secara global."\n\nVaksin universal ini bekerja dengan menargetkan bagian virus yang tidak berubah, berbeda dengan vaksin konvensional yang harus diperbarui setiap tahun. Hal ini memungkinkan perlindungan jangka panjang.\n\nPara ahli memperkirakan vaksin ini akan tersedia untuk publik dalam 6-12 bulan ke depan setelah mendapat persetujuan dari badan pengawas obat dan makanan di berbagai negara.',
    },
    {
      'judul': 'Platform E-Learning Gratis Diluncurkan untuk Pelajar Indonesia',
      'kategori': 'Pendidikan',
      'tanggal': '11 Desember 2024',
      'penulis': 'Edu News',
      'isi':
          'Kementerian Pendidikan meluncurkan platform e-learning gratis dengan konten lengkap untuk semua jenjang pendidikan. Platform ini diharapkan dapat meningkatkan akses pendidikan berkualitas di seluruh Indonesia.',
      'konten_lengkap':
          'Kementerian Pendidikan, Kebudayaan, Riset, dan Teknologi resmi meluncurkan platform e-learning nasional yang dapat diakses secara gratis oleh seluruh pelajar Indonesia. Platform ini menyediakan konten pembelajaran untuk semua jenjang dari SD hingga SMA.\n\n"Platform ini merupakan komitmen kami untuk menyediakan pendidikan berkualitas yang dapat diakses oleh semua anak Indonesia," kata Menteri Pendidikan dalam peluncuran platform.\n\nPlatform ini dilengkapi dengan lebih dari 10.000 video pembelajaran, latihan soal interaktif, dan ujian online. Konten disusun oleh para guru berpengalaman dan disesuaikan dengan kurikulum nasional.\n\nSelain itu, platform juga menyediakan fitur untuk orang tua memantau perkembangan belajar anak dan forum diskusi untuk siswa. Diharapkan platform ini dapat membantu mengurangi kesenjangan pendidikan di Indonesia.',
    },
    {
      'judul': 'Startup Lokal Raih Pendanaan Seri B Senilai 50 Juta Dolar',
      'kategori': 'Teknologi',
      'tanggal': '10 Desember 2024',
      'penulis': 'Tech Startup',
      'isi':
          'Startup teknologi Indonesia berhasil mengumpulkan pendanaan seri B sebesar 50 juta dolar dari investor internasional. Pendanaan ini akan digunakan untuk ekspansi ke pasar Asia Tenggara.',
      'konten_lengkap':
          'Startup teknologi Indonesia yang bergerak di bidang fintech berhasil mengamankan pendanaan seri B senilai 50 juta dolar dari konsorsium investor internasional yang dipimpin oleh venture capital terkemuka.\n\n"Pendanaan ini membuktikan kepercayaan investor terhadap potensi pasar Indonesia," kata CEO startup tersebut. "Kami akan menggunakan dana ini untuk memperluas layanan kami ke seluruh Asia Tenggara."\n\nStartup ini telah melayani lebih dari 2 juta pengguna aktif di Indonesia dan berencana menambah 500 karyawan baru dalam tahun depan. Mereka juga akan membuka kantor baru di Singapura dan Vietnam.\n\nPara analis melihat ini sebagai tanda positif bagi ekosistem startup Indonesia yang terus berkembang pesat.',
    },
    {
      'judul': 'Festival Musik Internasional Sukses Digelar di Jakarta',
      'kategori': 'Hiburan',
      'tanggal': '9 Desember 2024',
      'penulis': 'Entertainment',
      'isi':
          'Festival musik internasional berhasil menarik lebih dari 100.000 pengunjung selama tiga hari. Event ini menampilkan artis lokal dan internasional dengan sukses besar.',
      'konten_lengkap':
          'Jakarta menjadi tuan rumah festival musik internasional terbesar di Asia Tenggara tahun ini. Lebih dari 100.000 pengunjung memadati venue selama tiga hari acara berlangsung.\n\nFestival ini menampilkan lebih dari 50 artis dari berbagai genre musik, mulai dari pop, rock, jazz, hingga elektronik. Artis internasional yang tampil antara lain Coldplay, Ed Sheeran, dan BTS, sementara artis lokal seperti Raisa, Isyana Sarasvati, dan NIKI juga turut memeriahkan.\n\n"Event ini membuktikan bahwa Indonesia siap menjadi destinasi hiburan internasional," kata panitia penyelenggara. "Kami berharap ini dapat menjadi agenda tahunan."\n\nFestival ini juga memberikan dampak positif bagi perekonomian lokal dengan meningkatkan kunjungan wisatawan dan aktivitas bisnis di sekitar venue.',
    },
    {
      'judul': 'Penemuan Spesies Baru di Hutan Kalimantan',
      'kategori': 'Sains',
      'tanggal': '8 Desember 2024',
      'penulis': 'Science Daily',
      'isi':
          'Tim peneliti menemukan tiga spesies baru flora dan fauna di hutan Kalimantan. Penemuan ini menambah daftar keanekaragaman hayati Indonesia yang sudah dikenal sebagai megadiverse country.',
      'konten_lengkap':
          'Tim peneliti dari Lembaga Ilmu Pengetahuan Indonesia (LIPI) berhasil menemukan tiga spesies baru di hutan Kalimantan. Penemuan ini terdiri dari satu spesies tanaman dan dua spesies hewan.\n\n"Penemuan ini menunjukkan betapa kayanya keanekaragaman hayati Indonesia," kata ketua tim peneliti. "Kami masih terus melakukan eksplorasi dan yakin masih banyak spesies yang belum teridentifikasi."\n\nSpesies baru yang ditemukan antara lain tanaman anggrek endemik yang memiliki bunga berwarna ungu cerah, serta dua spesies katak kecil yang hidup di kanopi hutan. Penemuan ini telah dipublikasikan di jurnal ilmiah internasional.\n\nPara peneliti mengingatkan pentingnya konservasi hutan Kalimantan yang merupakan rumah bagi banyak spesies unik dan terancam punah.',
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

  IconData _getCategoryIcon(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'teknologi':
        return Icons.computer;
      case 'ekonomi':
        return Icons.trending_up;
      case 'olahraga':
        return Icons.sports_soccer;
      case 'kesehatan':
        return Icons.medical_services;
      case 'pendidikan':
        return Icons.school;
      case 'hiburan':
        return Icons.music_note;
      case 'sains':
        return Icons.science;
      default:
        return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Berita')),
      body: StreamBuilder(
        stream: _beritaService.getPublishedBerita(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          // Get berita from Firestore
          List<Map<String, dynamic>> beritaList = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            // Data dari Firestore
            beritaList = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              return {
                'id': doc.id,
                'judul': data?['judul'] ?? '',
                'kategori': data?['kategori'] ?? 'Lainnya',
                'isi': data?['isi'] ?? '',
                'kontenLengkap': data?['kontenLengkap'] ?? data?['isi'] ?? '',
                'penulis': data?['penulis'] ?? 'Admin',
                'imageUrl': data?['imageUrl'] as String?,
                'tanggal': _formatTimestamp(data?['createdAt']),
                'views': data?['views'] ?? 0,
              };
            }).toList();
          } else {
            // Fallback ke dummy data jika Firestore kosong
            beritaList = _dummyBeritaList;
          }

          if (beritaList.isEmpty) {
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: beritaList.length,
            itemBuilder: (context, index) {
              final berita = beritaList[index];
              final categoryColor = _getCategoryColor(berita['kategori']);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    _showBeritaDetail(context, berita);
                    // Increment views
                    if (berita['id'] != null) {
                      _beritaService.incrementViews(berita['id']);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      if (berita['imageUrl'] != null &&
                          berita['imageUrl'].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            berita['imageUrl'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 64),
                              );
                            },
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: categoryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      // ignore: deprecated_member_use
                                      color: categoryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getCategoryIcon(berita['kategori']),
                                        size: 14,
                                        color: categoryColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        berita['kategori'],
                                        style: TextStyle(
                                          color: categoryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                if (berita['tanggal'] != null)
                                  Text(
                                    berita['tanggal'],
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              berita['judul'],
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              berita['isi'],
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  berita['penulis'] ?? 'Admin',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const Spacer(),
                                if (berita['views'] != null &&
                                    berita['views'] > 0) ...[
                                  Icon(
                                    Icons.visibility,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${berita['views']}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Text(
                                  'Baca selengkapnya',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
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
            },
          );
        },
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

  void _showBeritaDetail(BuildContext context, Map<String, dynamic> berita) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Image
              if (berita['imageUrl'] != null &&
                  berita['imageUrl'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      berita['imageUrl'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 64),
                        );
                      },
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: _getCategoryColor(
                          berita['kategori'],
                          // ignore: deprecated_member_use
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: _getCategoryColor(
                            berita['kategori'],
                            // ignore: deprecated_member_use
                          ).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        berita['kategori'],
                        style: TextStyle(
                          color: _getCategoryColor(berita['kategori']),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      berita['judul'],
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    if (berita['tanggal'] != null)
                      Text(
                        berita['tanggal'],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Theme.of(
                            context,
                            // ignore: deprecated_member_use
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Oleh: ${berita['penulis'] ?? 'Admin'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (berita['views'] != null && berita['views'] > 0) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.visibility,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${berita['views']} views',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      berita['isi'] ?? '',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    if (berita['kontenLengkap'] != null &&
                        berita['kontenLengkap'].toString().isNotEmpty)
                      Text(
                        berita['kontenLengkap'],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
