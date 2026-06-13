import 'package:flutter/material.dart';
import 'booking_screen.dart';
import 'review_screen.dart';

class DetailDestinationScreen extends StatelessWidget {
  final String title;
  final String location;
  final String rating;
  final String imagePath;
  final String price;

  const DetailDestinationScreen({
    super.key,
    required this.title,
    required this.location,
    required this.rating,
    required this.imagePath,
    this.price = 'Rp 10.000',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFBEA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 320,
                  fit: BoxFit.cover,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFEFFBEA),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.black54,
                      ),
                      Text(
                        location,
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                      ),
                      Text(' $rating'),
                    ],
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Destinasi wisata pilihan di Provinsi Riau yang cocok untuk liburan, edukasi, dan menikmati keindahan budaya lokal.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color(0xFF007A33),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(' / orang'),
                    ],
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9F12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(
                              destinationName: title,
                              price: price,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Pesan Tiket Sekarang',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.star_rate,
                        color: Color(0xFF007A33),
                      ),
                      label: const Text(
                        'Lihat / Tulis Review',
                        style: TextStyle(
                          color: Color(0xFF007A33),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewScreen(
                              destinationName: title,
                            ),
                          ),
                        );
                      },
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