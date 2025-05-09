import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3A58D0);
    const Color primaryWhite = Colors.white;
    const Color inactiveGrey = Color(0xFFB5C0ED);
    const Color bodyBackground = Colors.black;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: primaryBlue,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: bodyBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'View',
          style: TextStyle(
            color: primaryWhite,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/question_icon.svg',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              print('Tombol Bantuan ditekan - Navigasi belum diatur');
            },
            tooltip: 'Help',
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: primaryWhite,
              size: 28,
            ),
            onPressed: () {
              print(
                  'Tombol Akun ditekan - Navigasi ke AccountScreen (DIKOMENTARI SEMENTARA)');
            },
            tooltip: 'Account',
          ),
          const SizedBox(width: 8),
        ],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: primaryBlue,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: bodyBackground,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 30.0,
                left: 20,
                right: 20,
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print('Tombol Speak to NetrAI ditekan');
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/mic_icon_white.svg',
                        width: 20,
                        height: 20,
                      ),
                      label: const Text('Speak to NetrAI'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: primaryWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.25),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCircularButton(
                          iconPath: 'assets/icons/switch_camera_icon_white.svg',
                          onPressed: () {
                            print('Tombol Switch Kamera ditekan');
                          },
                          buttonColor: primaryBlue,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        _buildCircularButton(
                          iconPath: 'assets/icons/camera_icon_white.svg',
                          onPressed: () {
                            print('Tombol Kamera ditekan');
                          },
                          buttonColor: primaryBlue,
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required String iconPath,
    required VoidCallback onPressed,
    required Color buttonColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: buttonColor.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        onPressed: onPressed,
        padding: const EdgeInsets.all(
          15,
        ),
        visualDensity: VisualDensity.compact,
        color: Colors.white,
      ),
    );
  }
}
