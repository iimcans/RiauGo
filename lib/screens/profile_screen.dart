import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'favorite_screen.dart';
import 'transaction_history_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'help_center_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    return doc.data();
  }

  Future<int> getTotalBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.length;
  }

  Future<int> getTotalFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.length;
  }

  Future<void> logout(BuildContext context) async {
    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
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
          'Profil Pengguna',
          style: TextStyle(
            color: Color(0xFF007A33),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          getUserData(),
          getTotalBooking(),
          getTotalFavorite(),
        ]),
        builder: (context, snapshot) {
          final data = snapshot.data?[0] as Map<String, dynamic>?;
          final totalBooking = snapshot.data?[1] ?? 0;
          final totalFavorite = snapshot.data?[2] ?? 0;

          final name = data?['name'] ?? 'Wisatawan';
          final email = data?['email'] ?? user?.email ?? '-';

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF007A33)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: const Color(0xFF007A33),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'W',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(email, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDF5D8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Premium Member',
                    style: TextStyle(
                      color: Color(0xFF007A33),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Expanded(
                      child: ProfileStat(title: '4', subtitle: 'Destinasi'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProfileStat(
                        title: totalBooking.toString(),
                        subtitle: 'Booking',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProfileStat(
                        title: totalFavorite.toString(),
                        subtitle: 'Favorit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  color: Colors.blue,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          currentName: name,
                          currentEmail: email,
                        ),
                      ),
                    );

                    if (result == true && context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    }
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.favorite,
                  title: 'Favorit Saya',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoriteScreen(),
                      ),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.receipt_long,
                  title: 'Transaction History',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransactionHistoryScreen(),
                      ),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.notifications_none,
                  title: 'Notification Settings',
                  color: Colors.grey,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpCenterScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => logout(context),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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

class ProfileStat extends StatelessWidget {
  final String title;
  final String subtitle;

  const ProfileStat({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF007A33),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}