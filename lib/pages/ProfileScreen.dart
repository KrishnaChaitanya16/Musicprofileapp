import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muiscprofileapp/pages/Homepage.dart';

class ProfileScreen extends StatelessWidget {
  final bool isOwnProfile;

  const ProfileScreen({Key? key, this.isOwnProfile = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full background image container
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Frame 316.png'), // Replace with your background image
                fit: BoxFit.cover,
                alignment: Alignment.topCenter, // Align the image to the top center
              ),
            ),
          ),
          // Gradient overlay to blend the color smoothly
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color.fromRGBO(18, 17, 17, 1),
                  ],
                ),
              ),
            ),
          ),
          // Wishlist icon top-left
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Image.asset('lib/icons/wishlist.png', height: 30, color: Color(0xFFfabee6)),
              onPressed: () {
                // Handle wishlist icon press
              },
            ),
          ),
          // Menu icon top-right
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(
                Icons.menu,
                color: Color(0xFFfabee6), // Custom color #fabee6
                size: 30,
              ),
              onPressed: () {
                // Handle menu icon press
              },
            ),
          ),
          // Profile details container
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileAvatar(),
                SizedBox(height: 20),
                Text(
                  'Username',
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Full Name',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '42 Links',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                if (isOwnProfile) // Show the Edit Profile button only if it's the current user's profile
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle edit profile button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(184, 55, 134, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: Icon(Icons.edit, color: Colors.white),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text(
                        'Edit Profile',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Your Posts section
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Your Posts',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.2),
                          image: DecorationImage(
                            image: AssetImage('assets/post_image.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Your Songs section
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.05,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Your Songs',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        width: 100,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.5),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: AssetImage('assets/song_image.png'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        selectedItemColor: Colors.white,
        onTap: (index) {
          // Handle navigation
          switch (index) {
            case 0:
              Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage()));
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/explore');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/new');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/inbox');
              break;
            case 4:
            // Already on Profile screen
              break;
          }
        },
        currentIndex: 4, // Set the current index of the BottomNavigationBar
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
            icon: CircleAvatar(
              radius: 14,
              backgroundImage: AssetImage(
                'lib/icons/profile_image.png',
              ), // Replace with your profile image asset
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({Key? key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 65,
          backgroundImage: AssetImage('assets/profile_image.png'),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 23,
              backgroundImage: AssetImage('lib/icons/qr-code.png'),
            ),
          ),
        ),
      ],
    );
  }
}
