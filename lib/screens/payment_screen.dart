import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentScreen extends StatefulWidget {
  final String destinationName;
  final String price;
  final int jumlahTiket;

  const PaymentScreen({
    super.key,
    required this.destinationName,
    required this.price,
    required this.jumlahTiket,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPayment = 'DANA';
  bool isLoading = false;

  final int discountPercent = 30;

  final List<String> paymentMethods = [
    'DANA',
    'OVO',
    'GoPay',
    'Transfer Bank',
    'Midtrans',
  ];

  int get ticketPrice {
    if (widget.price.toLowerCase().contains('gratis')) return 0;

    return int.tryParse(
          widget.price.replaceAll('Rp', '').replaceAll('.', '').trim(),
        ) ??
        0;
  }

  int get subtotal => ticketPrice * widget.jumlahTiket;

  int get discount => (subtotal * discountPercent / 100).round();

  int get totalPayment => subtotal - discount;

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  Future<void> bayarSekarang() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User belum login')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user.uid,
        'destinationName': widget.destinationName,
        'price': widget.price,
        'jumlahTiket': widget.jumlahTiket,
        'paymentMethod': selectedPayment,
        'subtotal': subtotal,
        'discountPercent': discountPercent,
        'discount': discount,
        'totalPayment': totalPayment,
        'status': 'Berhasil',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran berhasil, tiket tersimpan')),
      );

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal pembayaran: $e')),
      );
    }

    setState(() => isLoading = false);
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
          'Pembayaran',
          style: TextStyle(
            color: Color(0xFF007A33),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Ringkasan Pesanan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.destinationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Harga Tiket: ${widget.price}'),
                  Text('Jumlah Tiket: ${widget.jumlahTiket}'),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text(formatRupiah(subtotal)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Promo DISKON30',
                        style: TextStyle(color: Colors.orange),
                      ),
                      Text(
                        '- ${formatRupiah(discount)}',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Bayar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatRupiah(totalPayment),
                        style: const TextStyle(
                          color: Color(0xFF007A33),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            ...paymentMethods.map(
              (method) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedPayment == method
                        ? const Color(0xFF007A33)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: RadioListTile<String>(
                  value: method,
                  groupValue: selectedPayment,
                  activeColor: const Color(0xFF007A33),
                  onChanged: (value) {
                    setState(() {
                      selectedPayment = value!;
                    });
                  },
                  title: Text(
                    method,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  secondary: const Icon(Icons.account_balance_wallet),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : bayarSekarang,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9F12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Bayar ${formatRupiah(totalPayment)}',
                        style: const TextStyle(
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