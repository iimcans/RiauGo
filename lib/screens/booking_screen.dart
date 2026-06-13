import 'package:flutter/material.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String destinationName;
  final String price;

  const BookingScreen({
    super.key,
    required this.destinationName,
    required this.price,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int jumlahTiket = 1;

  void lanjutPembayaran() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          destinationName: widget.destinationName,
          price: widget.price,
          jumlahTiket: jumlahTiket,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFBEA),
      appBar: AppBar(
        title: const Text(
          'Booking Tiket',
          style: TextStyle(
            color: Color(0xFF007A33),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFEFFBEA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007A33)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Pemesanan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.destinationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.price,
                    style: const TextStyle(
                      color: Color(0xFF007A33),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jumlah Tiket',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (jumlahTiket > 1) {
                            setState(() {
                              jumlahTiket--;
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        jumlahTiket.toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            jumlahTiket++;
                          });
                        },
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF007A33),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
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
                onPressed: lanjutPembayaran,
                child: const Text(
                  'Lanjut Pembayaran',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}