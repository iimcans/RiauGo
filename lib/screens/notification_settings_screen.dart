import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool promoWisata = true;
  bool updateTiket = true;
  bool pengingatBooking = true;
  bool eventRiau = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFBEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFFBEA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007A33)),
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Color(0xFF007A33),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        children: [
          const Text(
            'Atur notifikasi RiauGo',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih notifikasi yang ingin kamu terima.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),

          NotificationTile(
            icon: Icons.local_offer_outlined,
            title: 'Promo Wisata',
            subtitle: 'Dapatkan info diskon dan promo destinasi.',
            value: promoWisata,
            onChanged: (value) {
              setState(() => promoWisata = value);
            },
          ),

          NotificationTile(
            icon: Icons.confirmation_number_outlined,
            title: 'Update Tiket',
            subtitle: 'Notifikasi status tiket dan pembayaran.',
            value: updateTiket,
            onChanged: (value) {
              setState(() => updateTiket = value);
            },
          ),

          NotificationTile(
            icon: Icons.alarm_outlined,
            title: 'Pengingat Booking',
            subtitle: 'Pengingat sebelum jadwal kunjungan.',
            value: pengingatBooking,
            onChanged: (value) {
              setState(() => pengingatBooking = value);
            },
          ),

          NotificationTile(
            icon: Icons.event_available_outlined,
            title: 'Event Riau',
            subtitle: 'Info acara wisata dan budaya di Riau.',
            value: eventRiau,
            onChanged: (value) {
              setState(() => eventRiau = value);
            },
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengaturan notifikasi berhasil disimpan'),
                  ),
                );
              },
              child: const Text(
                'Simpan Pengaturan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const NotificationTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF007A33),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}