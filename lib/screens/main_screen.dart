import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'history_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF3A58D0);
    const Color primaryWhite = Colors.white;
    const Color inactiveGrey = Color(0xFFB5C0ED);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _selectedIndex == 0
                  ? 'assets/icons/view_icon_active.svg'
                  : 'assets/icons/view_icon_inactive.svg',
              width: 24,
              height: 24,
            ),
            label: 'View',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _selectedIndex == 1
                  ? 'assets/icons/history_icon_active.svg'
                  : 'assets/icons/history_icon_inactive.svg',
              width: 24,
              height: 24,
            ),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryWhite,
        unselectedItemColor: inactiveGrey,
        onTap: _onItemTapped,
        backgroundColor: primaryBlue,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
      ),
    );
  }
}
