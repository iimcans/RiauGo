import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void mulai(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user == null ? const LoginScreen() : const MainScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/istana_siak.jpg',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.35)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A6B8),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.travel_explore,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'RiauGo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore Riau, Go Anywhere',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 45),
                SizedBox(
                  width: 240,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => mulai(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9F12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Mulai  →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 38,
            left: 0,
            right: 0,
            child: Text(
              'Versi 1.0.0 • Wisata Riau Digital',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}