import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFEFFBEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFFBEA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007A33)),
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            color: Color(0xFF007A33),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Silakan login terlebih dahulu'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF007A33),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada riwayat transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'Berhasil';
                    final isCancel = status == 'Dibatalkan';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isCancel
                                ? Colors.red.withOpacity(0.15)
                                : const Color(0xFFDDF5D8),
                            child: Icon(
                              isCancel
                                  ? Icons.cancel_outlined
                                  : Icons.check_circle_outline,
                              color: isCancel
                                  ? Colors.red
                                  : const Color(0xFF007A33),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['destinationName'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${data['jumlahTiket'] ?? 1} tiket • ${data['price'] ?? '-'}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  'Metode: ${data['paymentMethod'] ?? '-'}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            status,
                            style: TextStyle(
                              color: isCancel
                                  ? Colors.red
                                  : const Color(0xFF007A33),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}