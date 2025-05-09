import 'package:flutter/material.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://via.placeholder.com/400x800.png?text=Map+Placeholder'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLocationMarker(),
                  const SizedBox(height: 4),
                  const Text(
                    'Your Loved One',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Color(0xFF3A59D1),
                    ),
                  ),
                ],
              )),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 56.0 + topPadding,
              padding: EdgeInsets.only(
                top: topPadding,
                left: 16.0,
                right: 16.0,
              ),
              color: const Color(0xFF3A59D1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'View',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            size: 18, color: Color(0xFF3A59D1)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.mic, color: Colors.white),
                label: const Text(
                  'Speak to NetrAI',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A59D1),
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 5,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'fab_my_location',
                  mini: true,
                  onPressed: () {},
                  backgroundColor: const Color(0xFF3A59D1),
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'fab_pin_outline',
                  mini: true,
                  onPressed: () {},
                  backgroundColor: const Color(0xFF3A59D1),
                  child: const Icon(Icons.location_on_outlined,
                      color: Colors.white),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'fab_pin_filled',
                  mini: true,
                  onPressed: () {},
                  backgroundColor: const Color(0xFF3A59D1),
                  child: const Icon(Icons.location_on, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildLocationMarker() {
    return SizedBox(
      width: 70,
      height: 90,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            bottom: 20,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3A59D1).withOpacity(0.0),
                    const Color(0xFF3A59D1).withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3A59D1).withOpacity(0.1),
                border: Border.all(
                  color: const Color(0xFF8B9DE4),
                  width: 0.5,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10 + (36 - 16) / 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFF3A59D1),
                  width: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    const navBarColor = Color(0xFF3A59D1);

    const activeColor = Colors.white;

    const inactiveColor = Color(0xFFB5C0ED);

    return BottomAppBar(
      color: navBarColor,
      elevation: 8.0,
      height: 70.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildNavItem(context, Icons.location_on_outlined, 'Location', true,
              activeColor, inactiveColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      bool isActive, Color activeColor, Color inactiveColor,
      {VoidCallback? onTap}) {
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap ??
          () {
            if (!isActive) {
              print("Nav Item '$label' tapped");
            }
          },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
