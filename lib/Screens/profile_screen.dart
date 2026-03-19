import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';
import '../utils/app_colors.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Securely terminate the user session from Firebase and Google Identity
  Future<void> _signOut(BuildContext context) async {
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve currently authenticated user data
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final name = user?.displayName ?? 'Welcome User';
    final email = user?.email ?? 'No email linked';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Picture with elevated border styling
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor, width: 3),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 60, color: AppColors.primaryColor)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // User Identification Data
            Text(
              name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Interactive Account Options Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuOption(Icons.settings, 'Settings', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    }),
                    const Divider(height: 1, thickness: 1),
                    _buildMenuOption(Icons.security, 'Privacy & Security', () {
                      _showSecurityBottomSheet(context, email);
                    }),
                    const Divider(height: 1, thickness: 1),
                    _buildMenuOption(Icons.help_outline, 'Help & Support', () {
                      _showHelpDialog(context);
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Full-width Logout Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Modular widget to construct individual menu items
  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }


  // 1. HELP & SUPPORT DIALOG FUNCTION
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primaryColor.withOpacity(0.5), width: 1), // Glowing border feel
        ),
        contentPadding: const EdgeInsets.all(25),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium Support Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded, size: 60, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 20),

            const Text('Support Center', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            const Text(
              'Need assistance? Our 24/7 automated systems and support team are ready to help.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),

            // Khatarnak "Systems Online" Status Indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sensors, color: Colors.green, size: 20), // Radar/Sensor icon
                  SizedBox(width: 8),
                  Text('All Cloud Systems Online', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('App Version: 2.1.0 (Stable & Secured)', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DISMISS', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ],
      ),
    );
  }

  // 2. PRIVACY & SECURITY BOTTOM SHEET FUNCTION
  void _showSecurityBottomSheet(BuildContext context, String userEmail) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ye bottom sheet ko utna hi bada rakhta hai jitna content hai
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Text('Privacy & Security', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Manage your account security and data preferences.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),

            // Password Reset Feature via Firebase
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.lock_reset, color: Colors.orange),
              ),
              title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Receive a password reset link on email'),
              onTap: () async {
                Navigator.pop(context); // Bottom sheet ko close karne ke liye
                try {

                  await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset link sent to your email!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
            const Divider(),

            // Delete Data Visual Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.delete_forever, color: Colors.red),
              ),
              title: const Text('Delete Account & Data', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              subtitle: const Text('Permanently remove your data from servers'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Action restricted in demo mode to prevent accidental data loss.')),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}