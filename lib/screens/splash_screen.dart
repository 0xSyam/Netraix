import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndNavigate();
  }

  Future<void> _checkLoginStatusAndNavigate() async {
    await Future.delayed(Duration.zero);

    final authService = AuthService();

    final User? currentUser = await authService.authStateChanges.first;

    if (currentUser != null) {
      print(
          "[SplashScreen] Pengguna sudah login (${currentUser.uid}). Navigasi ke /main.");

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } else {
      print(
          "[SplashScreen] Pengguna belum login. Lanjutkan ke /welcome setelah delay.");

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF3A59D1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/images/logo.svg',
                  semanticsLabel: 'NetrAI Logo'),
              const SizedBox(
                height: 24,
              ),
              Text(
                'Helping you navigate daily life with confidence.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
