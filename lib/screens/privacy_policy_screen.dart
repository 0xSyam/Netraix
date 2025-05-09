import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _buildAgreementItem({
    required BuildContext context,
    required String iconPath,
    required String text,
    Color iconColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFB5C0ED),
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(
              right: 12.0,
            ),
            padding: const EdgeInsets.all(
              4,
            ),
            child: SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
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
    const double horizontalPadding = 30.0;
    const double buttonHeight = 51.0;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF3A58D0),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(
          0xFF3A58D0,
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Privacy and Terms',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
            height: 1.3,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF3A58D0),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'To use NetrAI, you agree to the following:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
                height: 1.21,
              ),
            ),
            const SizedBox(height: 24),
            _buildAgreementItem(
              context: context,
              iconPath: 'assets/icons/lock_icon.svg',
              text:
                  'I understand that NetrAI is not a mobility aid and should not replace my primary mobility device.',
            ),
            _buildAgreementItem(
              context: context,
              iconPath: 'assets/icons/camera_policy_icon.svg',
              text: 'NetrAI can record, review, and share videos for safety.',
            ),
            _buildAgreementItem(
              context: context,
              iconPath: 'assets/icons/data_icon.svg',
              text:
                  'The data, videos, and personal information I submit will be stored and processed in the NetrAI.',
            ),
            const Spacer(),
            const Text(
              'By clicking "I agree", I agree to everything above and accept the Terms of Service and Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: buttonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/main', (Route<dynamic> route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF3A58D0,
                  ),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      4.0,
                    ),
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
                child: const Text('I agree'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
