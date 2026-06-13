import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoadingProfile = false;
  bool isLoadingPassword = false;

  bool showPasswordForm = false;
  bool hideOld = true;
  bool hideNew = true;
  bool hideConfirm = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User belum login')),
      );
      return;
    }

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }

    setState(() => isLoadingProfile = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update profil: $e')),
      );
    }

    setState(() => isLoadingProfile = false);
  }

  Future<void> changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User belum login')),
      );
      return;
    }

    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field password wajib diisi')),
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru minimal 6 karakter')),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak sama')),
      );
      return;
    }

    setState(() => isLoadingPassword = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPasswordController.text.trim());

      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah')),
      );

      setState(() {
        showPasswordForm = false;
      });
    } on FirebaseAuthException catch (e) {
      String message = 'Gagal mengubah password';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Password lama salah';
      } else if (e.code == 'weak-password') {
        message = 'Password baru terlalu lemah';
      } else if (e.code == 'requires-recent-login') {
        message = 'Silakan login ulang terlebih dahulu';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    setState(() => isLoadingPassword = false);
  }

  Widget inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscureText,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: onTogglePassword == null
            ? null
            : IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: onTogglePassword,
              ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = nameController.text.trim().isNotEmpty
        ? nameController.text.trim()[0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFEFFBEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFFBEA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007A33)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF007A33),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: const Color(0xFF007A33),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  inputField(
                    label: 'Nama Lengkap',
                    controller: nameController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 18),
                  inputField(
                    label: 'Email',
                    controller: emailController,
                    icon: Icons.email_outlined,
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Email dibuat read-only agar login Firebase tetap aman.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoadingProfile ? null : updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9F12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoadingProfile
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Simpan Profil',
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

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFDDF5D8),
                      child: Icon(Icons.lock_reset, color: Color(0xFF007A33)),
                    ),
                    title: const Text(
                      'Ubah Password',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Ganti kata sandi akun RiauGo'),
                    trailing: Icon(
                      showPasswordForm
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onTap: () {
                      setState(() {
                        showPasswordForm = !showPasswordForm;
                      });
                    },
                  ),

                  if (showPasswordForm) ...[
                    const SizedBox(height: 18),
                    inputField(
                      label: 'Password Lama',
                      controller: oldPasswordController,
                      icon: Icons.lock_outline,
                      obscureText: hideOld,
                      onTogglePassword: () {
                        setState(() => hideOld = !hideOld);
                      },
                    ),
                    const SizedBox(height: 16),
                    inputField(
                      label: 'Password Baru',
                      controller: newPasswordController,
                      icon: Icons.lock_outline,
                      obscureText: hideNew,
                      onTogglePassword: () {
                        setState(() => hideNew = !hideNew);
                      },
                    ),
                    const SizedBox(height: 16),
                    inputField(
                      label: 'Konfirmasi Password Baru',
                      controller: confirmPasswordController,
                      icon: Icons.lock_outline,
                      obscureText: hideConfirm,
                      onTogglePassword: () {
                        setState(() => hideConfirm = !hideConfirm);
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed:
                            isLoadingPassword ? null : changePassword,
                        icon: const Icon(
                          Icons.save_outlined,
                          color: Color(0xFF007A33),
                        ),
                        label: isLoadingPassword
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF007A33),
                                ),
                              )
                            : const Text(
                                'Simpan Password Baru',
                                style: TextStyle(
                                  color: Color(0xFF007A33),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF007A33)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}