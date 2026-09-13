import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'postmodel.dart';
import 'halamandetail.dart';
import 'form_post_page.dart';

class Halamanblog extends StatefulWidget {
  const Halamanblog({super.key});

  @override
  State<Halamanblog> createState() => _HalamanblogState();
}

class _HalamanblogState extends State<Halamanblog> {
  int selectedCategoryIndex = 0;
  List categories = [];
  int? selectedKategoriId;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final fetchedData = await ApiService.fetchCategories();

      setState(() {
        categories = [
          {'namaKategori': 'All'},
          ...fetchedData,
        ];
      });
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  void _refreshPosts() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Discover",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            Text(
              "Blog Hewan Pengerat imup",
              style: TextStyle(fontFamily: 'Inter', fontSize: 15),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      // TOMBOL TAMBAH ARTIKEL (CREATE)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormPostPage()),
          );
          if (result == true) {
            _refreshPosts();
          }
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CHIP KATEGORI HORISONTAL
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 8),
            height: 40,
            child: categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedCategoryIndex == index;
                      final categoryName =
                          categories[index]['namaKategori'] ??
                          categories[index]['nama_kategori'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(categoryName),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedCategoryIndex = index;

                              if (index == 0) {
                                selectedKategoriId = null;
                              } else {
                                final cat = categories[index];
                                final rawId = cat['id'] ?? cat['id_kategori'] ?? cat['kategori_id'];
                                selectedKategoriId = rawId is int ? rawId : int.tryParse(rawId.toString());
                              }
                            });
                          },
                          selectedColor: Colors.black,
                          backgroundColor: const Color(0xFFF0F0F0),
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.transparent),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // BANNER UTAMA
                Container(
                  height: 250,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Image.network(
                          'assets/image/img_hamster1.jpg',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Container(color: Colors.black.withOpacity(0.35)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Makanan yang Sehat untuk Pencernaan Hamster',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  height: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(
                                      'assets/image/profile.png',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Miyo Cetiawan',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '3 hour ago',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'For You',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'See all',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // DAFTAR ARTIKEL BERDASARKAN KATEGORI SELECTED
                FutureBuilder<List<Post>>(
                  key: ValueKey(selectedKategoriId),
                  future: ApiService.fetchPosts(kategoriId: selectedKategoriId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text("Belum ada artikel untuk kategori ini."),
                        ),
                      );
                    }

                    final posts = snapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final item = posts[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPage(
                                        judul: item.judul,
                                        deskripsi: item.deskripsi,
                                        karakteristik: item.karakteristik,
                                        gambarUrl: Uri.encodeFull(
                                          "${ApiService.imageBaseUrl}/${item.gambar}.jpg",
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    Uri.encodeFull(
                                      "${ApiService.imageBaseUrl}/${item.gambar}.jpg",
                                    ),
                                    width: 110,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 110,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.pets,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                          judul: item.judul,
                                          deskripsi: item.deskripsi,
                                          karakteristik: item.karakteristik,
                                          gambarUrl: Uri.encodeFull(
                                            "${ApiService.imageBaseUrl}/${item.gambar}.jpg",
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.judul,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.deskripsi,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // TOMBOL OPSIONAL EDIT & DELETE (UPDATE & DELETE)
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FormPostPage(post: item),
                                      ),
                                    );
                                    if (updated == true) _refreshPosts();
                                  } else if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Hapus Artikel"),
                                        content: Text("Yakin ingin menghapus '${item.judul}'?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text("Batal"),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text(
                                              "Hapus",
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      final success = await ApiService.deletePost(item.id);
                                      if (success) {
                                        _refreshPosts();
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
                                        Text("Edit"),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red, size: 20),
                                        SizedBox(width: 8),
                                        Text("Hapus", style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}