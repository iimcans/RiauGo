import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewScreen extends StatefulWidget {
  final String destinationName;

  const ReviewScreen({
    super.key,
    required this.destinationName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final reviewController = TextEditingController();
  int selectedRating = 5;
  bool isLoading = false;

  Future<void> submitReview() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    if (reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan tidak boleh kosong')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'userId': user.uid,
        'email': user.email,
        'destinationName': widget.destinationName,
        'rating': selectedRating,
        'review': reviewController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review berhasil dikirim')),
      );

      reviewController.clear();
      setState(() => selectedRating = 5);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim review: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFBEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFFBEA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007A33)),
        title: const Text(
          'Review Destinasi',
          style: TextStyle(
            color: Color(0xFF007A33),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        children: [
          Text(
            widget.destinationName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Berikan rating dan ulasan untuk destinasi ini.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                const Text(
                  'Pilih Rating',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starNumber = index + 1;
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          selectedRating = starNumber;
                        });
                      },
                      icon: Icon(
                        starNumber <= selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.orange,
                        size: 36,
                      ),
                    );
                  }),
                ),
                Text(
                  '$selectedRating dari 5',
                  style: const TextStyle(
                    color: Color(0xFF007A33),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: reviewController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Tulis ulasan kamu di sini...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isLoading ? null : submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Kirim Review',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            'Review Pengguna',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reviews')
                .where('destinationName', isEqualTo: widget.destinationName)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF007A33),
                  ),
                );
              }

              final reviews = snapshot.data?.docs ?? [];

              if (reviews.isEmpty) {
                return const Text(
                  'Belum ada review untuk destinasi ini.',
                  style: TextStyle(color: Colors.black54),
                );
              }

              return Column(
                children: reviews.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['email'] ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < (data['rating'] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.orange,
                              size: 20,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(data['review'] ?? '-'),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}