import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_screen.dart';
import 'contact_us_screen.dart';
import 'welcome_screen.dart';

class AccountScreen extends StatelessWidget {
  final String? displayName;
  final String? email;
  final String? photoURL;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AccountScreen({
    super.key,
    this.displayName,
    this.email,
    this.photoURL,
  });

  Widget _buildActionItem({
    required BuildContext context,
    required String iconPath,
    required String text,
    required VoidCallback onTap,
    double iconWidth = 24.0,
    double iconHeight = 24.0,
    double gap = 12.0,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: iconWidth,
              height: iconHeight,
              colorFilter:
                  const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
            SizedBox(width: gap),
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      print("Google Sign-Out successful");

      await FirebaseAuth.instance.signOut();
      print("Firebase Auth Sign-Out successful");

      await FirebaseAuth.instance.authStateChanges().first;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Error signing out: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: 290,
      height: 51,
      decoration: BoxDecoration(
        color: const Color(0xFF3A59D1),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _signOut(context),
          borderRadius: BorderRadius.circular(8.0),
          child: const Center(
            child: Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        leading: IconButton(
          icon: Image.asset('assets/images/arrow_back.png', height: 24),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 100.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFD9D9D9),
                          backgroundImage:
                              photoURL != null && photoURL!.isNotEmpty
                                  ? NetworkImage(photoURL!)
                                  : null,
                          child: (photoURL == null || photoURL!.isEmpty) &&
                                  (displayName != null &&
                                      displayName!.isNotEmpty)
                              ? Text(
                                  displayName![0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.black54,
                                  ),
                                )
                              : (photoURL == null || photoURL!.isEmpty)
                                  ? const Icon(Icons.person,
                                      size: 28, color: Colors.black54)
                                  : null,
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName ?? 'Nama Pengguna',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter',
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                email ?? 'email@example.com',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF828282),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  _buildActionItem(
                    context: context,
                    iconPath: 'assets/images/add_family_account_icon.svg',
                    text: 'Add family account',
                    gap: 13.0,
                    onTap: () {
                      print('Add family account tapped');
                    },
                  ),
                  _buildActionItem(
                    context: context,
                    iconPath: 'assets/images/settings_icon.svg',
                    text: 'NetrAI settings',
                    gap: 14.0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionItem(
                    context: context,
                    iconPath: 'assets/images/contact_us_icon.svg',
                    text: 'Contact us',
                    gap: 11.0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: _buildLogoutButton(context),
            ),
          ),
        ],
      ),
    );
  }
}
