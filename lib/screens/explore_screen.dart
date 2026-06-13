import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'detail_destination_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String selectedCategory = 'Semua';
  String searchQuery = '';

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> wisata = const [
    {
      'nama': 'Istana Siak Sri Indrapura',
      'lokasi': 'Siak, Riau',
      'rating': '4.8',
      'gambar': 'assets/images/istana_siak.jpg',
      'harga': 'Rp 10.000',
      'kategori': 'Budaya',
    },
    {
      'nama': 'Candi Muara Takus',
      'lokasi': 'Kampar, Riau',
      'rating': '4.7',
      'gambar': 'assets/images/muara_takus.jpg',
      'harga': 'Rp 10.000',
      'kategori': 'Budaya',
    },
    {
      'nama': 'Hutan Mangrove',
      'lokasi': 'Dumai, Riau',
      'rating': '4.6',
      'gambar': 'assets/images/mangrove.jpg',
      'harga': 'Rp 15.000',
      'kategori': 'Alam',
    },
    {
      'nama': 'Masjid Raya An-Nur',
      'lokasi': 'Pekanbaru, Riau',
      'rating': '4.9',
      'gambar': 'assets/images/masjid_annur.jpg',
      'harga': 'Gratis',
      'kategori': 'Religi',
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String favoriteDocId(String title) {
    final user = FirebaseAuth.instance.currentUser;
    return '${user!.uid}_$title';
  }

  Future<void> toggleFavorite({
    required BuildContext context,
    required String title,
    required String location,
    required String rating,
    required String imagePath,
    required String price,
    required String category,
    required bool isFavorite,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    final docId = favoriteDocId(title);
    final favoriteRef =
        FirebaseFirestore.instance.collection('favorites').doc(docId);

    if (isFavorite) {
      await favoriteRef.delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dihapus dari favorit')),
      );
    } else {
      await favoriteRef.set({
        'userId': user.uid,
        'title': title,
        'location': location,
        'rating': rating,
        'imagePath': imagePath,
        'price': price,
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ditambahkan ke favorit')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final filteredWisata = wisata.where((item) {
      final nama = item['nama']!.toLowerCase();
      final lokasi = item['lokasi']!.toLowerCase();
      final kategori = item['kategori']!.toLowerCase();
      final query = searchQuery.toLowerCase();

      final cocokSearch =
          nama.contains(query) || lokasi.contains(query) || kategori.contains(query);

      final cocokKategori =
          selectedCategory == 'Semua' || item['kategori'] == selectedCategory;

      return cocokSearch && cocokKategori;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEFFBEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFFBEA),
        elevation: 0,
        title: const Text(
          'Eksplor Riau',
          style: TextStyle(
            color: Color(0xFF007A33),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Color(0xFF007A33)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: user == null
            ? const Stream.empty()
            : FirebaseFirestore.instance
                .collection('favorites')
                .where('userId', isEqualTo: user.uid)
                .snapshots(),
        builder: (context, favoriteSnapshot) {
          final favoriteTitles = favoriteSnapshot.hasData
              ? favoriteSnapshot.data!.docs
                  .map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['title'].toString();
                  })
                  .toSet()
              : <String>{};

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Mau liburan ke mana hari ini?',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChipWidget(
                        label: 'Semua',
                        active: selectedCategory == 'Semua',
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Semua';
                          });
                        },
                      ),
                      FilterChipWidget(
                        label: 'Alam',
                        active: selectedCategory == 'Alam',
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Alam';
                          });
                        },
                      ),
                      FilterChipWidget(
                        label: 'Budaya',
                        active: selectedCategory == 'Budaya',
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Budaya';
                          });
                        },
                      ),
                      FilterChipWidget(
                        label: 'Religi',
                        active: selectedCategory == 'Religi',
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Religi';
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  selectedCategory == 'Semua'
                      ? 'Destinasi Populer'
                      : 'Kategori $selectedCategory',
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilihan terbaik untuk petualanganmu',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 18),

                if (filteredWisata.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        'Destinasi tidak ditemukan',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                ...filteredWisata.map(
                  (item) {
                    final isFavorite = favoriteTitles.contains(item['nama']);

                    return ExploreCard(
                      title: item['nama']!,
                      location: item['lokasi']!,
                      rating: item['rating']!,
                      imagePath: item['gambar']!,
                      price: item['harga']!,
                      category: item['kategori']!,
                      isFavorite: isFavorite,
                      onFavoriteTap: () {
                        toggleFavorite(
                          context: context,
                          title: item['nama']!,
                          location: item['lokasi']!,
                          rating: item['rating']!,
                          imagePath: item['gambar']!,
                          price: item['harga']!,
                          category: item['kategori']!,
                          isFavorite: isFavorite,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF007A33) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class ExploreCard extends StatelessWidget {
  final String title;
  final String location;
  final String rating;
  final String imagePath;
  final String price;
  final String category;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const ExploreCard({
    super.key,
    required this.title,
    required this.location,
    required this.rating,
    required this.imagePath,
    required this.price,
    required this.category,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailDestinationScreen(
              title: title,
              location: location,
              rating: rating,
              imagePath: imagePath,
              price: price,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  child: Image.asset(
                    imagePath,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : const Color(0xFF007A33),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 17,
                        color: Colors.black54,
                      ),
                      Text(
                        location,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      Text(' $rating'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Color(0xFF007A33),
                      fontWeight: FontWeight.bold,
                    ),
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