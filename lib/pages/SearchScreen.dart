import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1f0d1d),
                  Color(0xFF140f13),
                ],
                stops: [0.01, 0.1],
              ),
            ),
          ),
          // Your content for ExploreScreen
          Center(
            child: Text(
              'Explore Screen Content',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        selectedItemColor: Colors.white,
        currentIndex: 1, // Adjust index as needed for current tab
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('lib/icons/home.png', width: 24, height: 24, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('lib/icons/orbits.png', width: 24, height: 24, color: Colors.white),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('lib/icons/more.png', width: 24, height: 24, color: Colors.white),
            label: 'New',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('lib/icons/inbox.png', width: 24, height: 24, color: Colors.white),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14,
              backgroundImage: AssetImage('lib/icons/profile_image.png'), // Replace with your profile image asset
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
