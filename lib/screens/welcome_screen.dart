import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _buildFeatureItem({
    required String iconPath,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 7.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 32,
            height: 32,
          ),
          const SizedBox(
            width: 19.0,
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF3A58D0),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    const double horizontalPadding = 35.0;
    const double buttonHeight = 51.0;
    const double imageSize = 200.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A58D0),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'NetrAI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            height: 1.33,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF3A58D0),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Making everyday moments easier, one step at a time.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildFeatureItem(
                      iconPath: 'assets/icons/camera_icon.svg',
                      description:
                          'With NetrAI, your camera becomes a smart assistant—reading text, finding objects, exploring spaces, and guiding you through your day with confidence.',
                    ),
                    _buildFeatureItem(
                      iconPath: 'assets/icons/mic_icon.svg',
                      description:
                          'Need help on the go? Just ask NetrAI, your voice-powered companion for independent living.',
                    ),
                    _buildFeatureItem(
                      iconPath: 'assets/icons/lamp_icon.svg',
                      description:
                          'Get real-time guidance! NetrAI provides helpful voice tips when using the camera—letting you know if you\\\'re too close, too shaky, or need to adjust your angle.',
                    ),
                    _buildFeatureItem(
                      iconPath: 'assets/icons/pin_icon.svg',
                      description:
                          'NetrAI helps families stay connected by sharing live location, so loved ones can feel close and supported—wherever they are.',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A58D0),
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print("Tombol 'I Need Visual Assistance' ditekan");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          height: 1.21,
                        ),
                        elevation: 0,
                      ),
                      child: const Text('I Need Visual Assistance'),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A58D0),
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print("Tombol 'I'm Supporting a Loved One' ditekan");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          height: 1.21,
                        ),
                        elevation: 0,
                      ),
                      child: const Text('I\'m Supporting a Loved One'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
