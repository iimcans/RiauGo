import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'Bagaimana cara memesan tiket?',
        'answer':
            'Pilih destinasi wisata, buka detail destinasi, klik Pesan Tiket, pilih jumlah tiket, lalu lakukan pembayaran.',
      },
      {
        'question': 'Bagaimana cara membatalkan tiket?',
        'answer':
            'Masuk ke menu Tiket Saya, pilih tiket yang masih aktif, lalu klik Batalkan Tiket.',
      },
      {
        'question': 'Apakah tiket tersimpan otomatis?',
        'answer':
            'Ya, tiket yang sudah berhasil dibayar akan tersimpan otomatis di menu Tiket Saya.',
      },
      {
        'question': 'Bagaimana cara menyimpan favorit?',
        'answer':
            'Klik ikon hati pada destinasi di halaman Explore. Destinasi favorit akan muncul di menu Favorit Saya.',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFFBEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFFBEA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007A33)),
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: Color(0xFF007A33),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF007A33),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.support_agent, color: Colors.white, size: 42),
                SizedBox(height: 14),
                Text(
                  'Ada yang bisa kami bantu?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Temukan jawaban seputar penggunaan aplikasi RiauGo.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Pertanyaan Umum',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...faqs.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ExpansionTile(
                iconColor: const Color(0xFF007A33),
                collapsedIconColor: const Color(0xFF007A33),
                title: Text(
                  item['question']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      item['answer']!,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'Kontak Admin',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          const ContactTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@riaugo.id',
          ),
          const ContactTile(
            icon: Icons.phone_outlined,
            title: 'WhatsApp',
            subtitle: '+62 812-3456-7890',
          ),
          const ContactTile(
            icon: Icons.location_on_outlined,
            title: 'Alamat',
            subtitle: 'Pekanbaru, Provinsi Riau',
          ),
        ],
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ContactTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFDDF5D8),
            child: Icon(icon, color: const Color(0xFF007A33)),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}