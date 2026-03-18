import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/app_colors.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

//  Core Function: Handles the new Google Sign-In process (v7+)
  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
// 1. New method: Taking Singleton instance (no constructor)
      final googleSignIn = GoogleSignIn.instance;

//Inside the initialize function you have to put your client Id
    await googleSignIn.initialize(
//  Paste your Firebase Web Client ID here 👇
        serverClientId: '266312093802-44br4v7rlpnt63cq2kn9r17c0on4ok9l.apps.googleusercontent.com',
      );

      // 2. Trigger the Google Authentication popup (signIn ki jagah authenticate)
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      if (googleUser == null) {
        setState(() { _isLoading = false; });
        return;
      }

// 3. Got the Idtoken (Now 'Avait' is not needed here)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

// 4. New rule: Scopes need to be requested separately to obtain access tokens
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);

      // 5. Create a new credential for Firebase dono tokens use karke
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

// 6. Sign in to Firebase with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 7. Navigate to the Home Screen upon successful login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 80,
                      color: AppColors.primaryColor
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Expense Tracker",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Manage your money like a pro!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 50),
                _isLoading
                    ? const CircularProgressIndicator(color: AppColors.primaryColor)
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  onPressed: signInWithGoogle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://cdn-icons-png.flaticon.com/512/300/300221.png',
                        height: 24,
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        "Continue with Google",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}