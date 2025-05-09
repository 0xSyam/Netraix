import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _hapticFeedbackKey = 'haptic_feedback_preference';
  static const String _automaticFlashlightKey =
      'automatic_flashlight_preference';
  static const String _cameraGuidanceKey = 'camera_guidance_preference';
  static const String _showToolbarKey = 'show_toolbar_preference';

  bool _automaticFlashlight = false;
  bool _cameraGuidance = false;
  bool _hapticFeedback = false;

  bool _isAiVoiceExpanded = false;
  bool _showToolbar = true;
  bool _resetToDefault = false;
  double _speechRate = 0.5;
  double _pitch = 0.5;
  String _selectedGender = 'male';

  Widget _buildToggleSettingItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                    color: Colors.black.withOpacity(
                      0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3A59D1),
            inactiveTrackColor: const Color(0xFFD9D9D9),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSettingItem({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            min: 0.0,
            max: 1.0,
            activeColor: Colors.grey.shade600,
            inactiveColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audio gender options',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Radio<String>(
                value: 'male',
                groupValue: _selectedGender,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                    });
                  }
                },
                activeColor: Colors.grey.shade600,
              ),
              const Text('Male'),
              const SizedBox(width: 20),
              Radio<String>(
                value: 'female',
                groupValue: _selectedGender,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                    });
                  }
                },
                activeColor: Colors.grey.shade600,
              ),
              const Text('Female'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hapticFeedback = prefs.getBool(_hapticFeedbackKey) ?? false;
      _automaticFlashlight = prefs.getBool(_automaticFlashlightKey) ?? false;
      _cameraGuidance = prefs.getBool(_cameraGuidanceKey) ?? false;
      _showToolbar = prefs.getBool(_showToolbarKey) ?? true;
    });
  }

  Future<void> _saveBoolPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade200,
        leading: IconButton(
          icon: Image.asset('assets/images/arrow_back.png', height: 24),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text(
          'Reading Tools Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildToggleSettingItem(
            title: 'Automatic flashlight',
            subtitle:
                'Automatically use your flashlight to improve object identification',
            value: _automaticFlashlight,
            onChanged: (bool value) {
              setState(() {
                _automaticFlashlight = value;
              });
              _saveBoolPreference(_automaticFlashlightKey, value);
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildToggleSettingItem(
            title: 'Camera guidance',
            subtitle:
                'Get voice tips and distance information in positioning your phone',
            value: _cameraGuidance,
            onChanged: (bool value) {
              setState(() {
                _cameraGuidance = value;
              });
              _saveBoolPreference(_cameraGuidanceKey, value);
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildToggleSettingItem(
            title: 'Haptic feedback',
            subtitle: 'Subtle vibration feedback during use',
            value: _hapticFeedback,
            onChanged: (bool value) async {
              setState(() {
                _hapticFeedback = value;
              });
              await _saveBoolPreference(_hapticFeedbackKey, value);
              if (value) {
                final canVibrate = await Haptics.canVibrate();
                if (canVibrate) {
                  await Haptics.vibrate(HapticsType.light);
                }
              }
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ExpansionTile(
            key: PageStorageKey('ai_voice_settings'),
            title: const Text(
              'AI voice settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              'Manage toolbar and AI speech options',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            trailing: SvgPicture.asset(
              'assets/images/chevron_down_icon.svg',
              height: 18,
              colorFilter: ColorFilter.mode(
                Colors.grey.shade500,
                BlendMode.srcIn,
              ),
            ),
            onExpansionChanged: (bool expanded) {
              setState(() {
                _isAiVoiceExpanded = expanded;
              });
            },
            initiallyExpanded: _isAiVoiceExpanded,
            tilePadding: const EdgeInsets.symmetric(
              vertical: 0.0,
              horizontal: 16.0,
            ),
            childrenPadding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 10.0,
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1),
              _buildToggleSettingItem(
                title: 'Show toolbar for playback and display option',
                subtitle: '',
                value: _showToolbar,
                onChanged: (bool value) {
                  setState(() {
                    _showToolbar = value;
                  });
                  _saveBoolPreference(_showToolbarKey, value);
                },
              ),
              _buildToggleSettingItem(
                title: 'Reset to default',
                subtitle: '',
                value: _resetToDefault,
                onChanged: (bool value) {
                  setState(() {
                    _resetToDefault = value;
                    if (value) {
                      _speechRate = 0.5;
                      _pitch = 0.5;
                      _selectedGender = 'male';
                    }
                  });
                },
              ),
              _buildSliderSettingItem(
                label: 'Speech rate',
                value: _speechRate,
                onChanged: (double value) {
                  setState(() {
                    _speechRate = value;
                  });
                },
              ),
              _buildSliderSettingItem(
                label: 'Pitch',
                value: _pitch,
                onChanged: (double value) {
                  setState(() {
                    _pitch = value;
                  });
                },
              ),
              _buildGenderOptions(),
            ],
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ),
    );
  }
}
