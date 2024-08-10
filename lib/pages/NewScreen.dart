import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muiscprofileapp/pages/CreatePost.dart';
import 'package:muiscprofileapp/pages/HostJam.dart';
import 'package:muiscprofileapp/pages/ScheduleJam.dart';
import 'package:provider/provider.dart';
import 'package:muiscprofileapp/pages/ChatPage.dart';
import 'package:muiscprofileapp/pages/Homepage.dart';
import 'package:muiscprofileapp/pages/ProfileScreen.dart';
import 'package:muiscprofileapp/pages/SearchScreen.dart';
import 'package:muiscprofileapp/pages/NotificationsScreen.dart';
import 'package:muiscprofileapp/providers/BottomNavBarprovider.dart'; // Assuming you have a BottomNavigationBarProvider

class NewScreen extends StatefulWidget {
  const NewScreen({Key? key}) : super(key: key);

  @override
  _NewScreenState createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  late PageController _pageController;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  Future<String?> _fetchProfileImageUrl() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID
      if (userId == null) return null;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final imageUrl = userData?['imageUrl'];
        // Log URL
        return imageUrl;
      }
      return null;
    } catch (e) {
      print('Error fetching profile image URL: $e');
      return null;
    }
  }

  void _onTabTapped(BuildContext context, int index) {
    final navigationProvider = Provider.of<BottomNavigationBarProvider>(
      context,
      listen: false,
    );

    if (navigationProvider.currentIndex == index) {
      return; // Do nothing if already on the same tab
    }

    navigationProvider.setIndex(index);

    // Perform navigation based on index
    switch (index) {
      case 0:
      // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
      // Navigate to ExploreScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ExploreScreen()),
        );
        break;
      case 2:
      // Navigate to NewScreen (current screen)
        break;
      case 3:
      // Navigate to NotificationsScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NotificationsScreen()),
        );
        break;
      case 4:
      // Navigate to ProfileScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BottomNavigationBarProvider>(context);
    final int currentIndex = provider.currentIndex;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Frame 316.png'), // Replace with your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent, // Transparent background to show the image
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 15),
                  Container(
                    width: 320,
                    height: 80,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10), // Padding to make container bigger
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> HostJam(channelName: "musicprofileapp",)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(184, 55, 134, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          minimumSize: Size(double.infinity, 60), // Set minimum size to fill container
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Host a Jam',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            Icon(Icons.music_note, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 320,
                    height: 80,
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10), // Padding to make container bigger
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> ScheduleJam(channelName: "musicprofileapp")));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(184, 55, 134, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          minimumSize: Size(double.infinity, 60), // Set minimum size to fill container
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Schedule a Jam',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            Icon(Icons.schedule, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 320,
                    height: 80,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10), // Padding to make container bigger
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context)=> CreatePost()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(184, 55, 134, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          minimumSize: Size(double.infinity, 60), // Set minimum size to fill container
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Post',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            Icon(Icons.post_add, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        selectedItemColor: Colors.white,
        onTap: (index) => _onTabTapped(context, index),
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/icons/home.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/icons/orbits.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/icons/more.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
            label: 'New',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/icons/inbox.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: FutureBuilder<String?>(
              future: _fetchProfileImageUrl(), // Fetch the profile image URL from Firebase
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    radius: 14,
                    child: CircularProgressIndicator(), // Loading indicator
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  print('Error or no data: ${snapshot.error}'); // Log error
                  return CircleAvatar(
                    radius: 14,
                    backgroundImage: AssetImage('lib/icons/profile_image.png'), // Fallback image
                  );
                }
                final imageUrl = snapshot.data!;
                return CircleAvatar(
                  radius: 19,
                  backgroundImage: NetworkImage(imageUrl), // Use the fetched image URL
                );
              },
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
