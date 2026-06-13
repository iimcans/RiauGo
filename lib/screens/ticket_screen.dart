import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  Future<void> cancelTicket(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('bookings').doc(docId).update({
      'status': 'Dibatalkan',
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tiket berhasil dibatalkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFEFFBEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFFBEA),
        elevation: 0,
        title: const Text(
          'Tiket Saya',
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
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF007A33),
                    ),
                  );
                }

                final tickets = snapshot.data?.docs ?? [];

                if (tickets.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada tiket yang dipesan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final doc = tickets[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final status = data['status'] ?? 'Berhasil';
                    final isCancelled = status == 'Dibatalkan';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.confirmation_number,
                                color: isCancelled
                                    ? Colors.red
                                    : const Color(0xFF007A33),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'E-Tiket Resmi',
                                style: TextStyle(
                                  color: isCancelled
                                      ? Colors.red
                                      : const Color(0xFF007A33),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isCancelled
                                      ? Colors.red.withOpacity(0.12)
                                      : const Color(0xFFDDF5D8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: isCancelled
                                        ? Colors.red
                                        : const Color(0xFF007A33),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data['destinationName'] ?? '-',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Jumlah Tiket: ${data['jumlahTiket'] ?? 1}'),
                          const SizedBox(height: 4),
                          Text('Harga: ${data['price'] ?? '-'}'),
                          const SizedBox(height: 4),
                          Text(
                            'Metode Bayar: ${data['paymentMethod'] ?? '-'}',
                          ),
                          const SizedBox(height: 16),

                          if (!isCancelled)
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title:
                                            const Text('Batalkan Tiket?'),
                                        content: const Text(
                                          'Apakah kamu yakin ingin membatalkan tiket ini?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                            },
                                            child: const Text('Tidak'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                              cancelTicket(context, doc.id);
                                            },
                                            child: const Text(
                                              'Ya, Batalkan',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Batalkan Tiket',
                                  style: TextStyle(color: Colors.red),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
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