import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'detail_destination_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Semua';
  String searchQuery = '';

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  late Future<Map<String, dynamic>?> userFuture;

  final List<Map<String, String>> destinations = const [
    {
      'title': 'Istana Siak Sri Indrapura',
      'location': 'Siak, Riau',
      'price': 'Rp 10.000',
      'rating': '4.8',
      'category': 'Budaya',
      'image': 'assets/images/istana_siak.jpg',
    },
    {
      'title': 'Candi Muara Takus',
      'location': 'Kampar, Riau',
      'price': 'Rp 10.000',
      'rating': '4.7',
      'category': 'Sejarah',
      'image': 'assets/images/muara_takus.jpg',
    },
    {
      'title': 'Hutan Mangrove',
      'location': 'Dumai, Riau',
      'price': 'Rp 15.000',
      'rating': '4.6',
      'category': 'Alam',
      'image': 'assets/images/mangrove.jpg',
    },
    {
      'title': 'Masjid Raya An-Nur',
      'location': 'Pekanbaru, Riau',
      'price': 'Gratis',
      'rating': '4.9',
      'category': 'Religi',
      'image': 'assets/images/masjid_annur.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    userFuture = getUserData();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  Future<void> logout(BuildContext context) async {
    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDestinations = destinations.where((item) {
      final matchCategory =
          selectedCategory == 'Semua' || item['category'] == selectedCategory;

      final query = searchQuery.toLowerCase();

      final matchSearch = item['title']!.toLowerCase().contains(query) ||
          item['location']!.toLowerCase().contains(query) ||
          item['category']!.toLowerCase().contains(query);

      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEFFBEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFFBEA),
        elevation: 0,
        title: const Text(
          'RiauGo',
          style: TextStyle(
            color: Color(0xFF007A33),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: userFuture,
        builder: (context, snapshot) {
          final userData = snapshot.data;
          final name = userData?['name'] ?? 'Wisatawan';

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF007A33)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $name 👋',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mau jalan-jalan ke mana hari ini?',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 22),

                TextField(
                  controller: searchController,
                  focusNode: searchFocus,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari destinasi impianmu...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                searchQuery = '';
                              });
                              searchFocus.requestFocus();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const PromoBanner(),

                const SizedBox(height: 26),
                const Text(
                  'Kategori',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryItem(
                      icon: Icons.all_inclusive,
                      label: 'Semua',
                      active: selectedCategory == 'Semua',
                      onTap: () => setState(() => selectedCategory = 'Semua'),
                    ),
                    CategoryItem(
                      icon: Icons.landscape,
                      label: 'Alam',
                      active: selectedCategory == 'Alam',
                      onTap: () => setState(() => selectedCategory = 'Alam'),
                    ),
                    CategoryItem(
                      icon: Icons.account_balance,
                      label: 'Budaya',
                      active: selectedCategory == 'Budaya',
                      onTap: () => setState(() => selectedCategory = 'Budaya'),
                    ),
                    CategoryItem(
                      icon: Icons.mosque,
                      label: 'Religi',
                      active: selectedCategory == 'Religi',
                      onTap: () => setState(() => selectedCategory = 'Religi'),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                Text(
                  selectedCategory == 'Semua'
                      ? 'Destinasi Pilihan'
                      : 'Kategori $selectedCategory',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),

                if (filteredDestinations.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        'Destinasi tidak ditemukan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                ...filteredDestinations.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: DestinationCard(
                      title: item['title']!,
                      location: item['location']!,
                      price: item['price']!,
                      rating: item['rating']!,
                      imagePath: item['image']!,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF007A33),
            Color(0xFF00B050),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROMO WISATA RIAU',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Diskon tiket\nhingga 30%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Khusus bulan ini untuk pengguna RiauGo',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number,
              color: Colors.white,
              size: 46,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF007A33) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: active ? Colors.white : const Color(0xFF007A33),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? const Color(0xFF007A33) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String title;
  final String location;
  final String price;
  final String rating;
  final String imagePath;

  const DestinationCard({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
    required this.imagePath,
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
        height: 132,
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                imagePath,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(location, style: const TextStyle(color: Colors.black54)),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      Text(' $rating'),
                      const Spacer(),
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color(0xFF007A33),
                          fontWeight: FontWeight.bold,
                        ),
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