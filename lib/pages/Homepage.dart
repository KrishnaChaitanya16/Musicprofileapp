import 'package:flutter/material.dart';
import 'package:muiscprofileapp/pages/ActivityPage.dart';
import 'package:muiscprofileapp/providers/BottomNavBarprovider.dart';
import 'package:provider/provider.dart';
import 'package:muiscprofileapp/pages/NewScreen.dart';
import 'package:muiscprofileapp/pages/NotificationsScreen.dart';
import 'package:muiscprofileapp/pages/ProfileScreen.dart';
import 'package:muiscprofileapp/pages/SearchScreen.dart';
 // Import ExploreScreen

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isExpanded = false; // Moved isExpanded to class scope

  void _onTabTapped(int index) {
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
      // Handle navigation or perform action for the Home tab
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
      // Navigate to ExploreScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ExploreScreen()),
        );
        break;
      case 2:
      // Navigate to NewScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewScreen()),
        );
        break;
      case 3:
      // Navigate to NotificationsScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationsScreen()),
        );
        break;
      case 4:
      // Navigate to ProfileScreen
        Navigator.push(
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
                stops: [0.1, 0.2],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(16, 50, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle notifications tap
                      },
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>ActivityPage()));
                        },
                        child: Icon(
                          Icons.notifications,
                          color: Colors.white,


                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFffc7ee),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('lib/icons/hotspot.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Jam',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.white.withOpacity(0.3),
                thickness: 1,
                height: 1,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 10, // Replace with your actual number of items
                  itemBuilder: (context, index) {
                    return _buildListItem(); // Function to build each list item
                  },
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavigationBar(
              backgroundColor: Colors.black,
              unselectedItemColor: Colors.white.withOpacity(0.6),
              selectedItemColor: Colors.white,
              onTap: (index) => _onTabTapped(index),
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
          ),
        ],
      ),
    );
  }

  Widget _buildListItem() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF140f13), // Match page background color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User info row
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(
                        'lib/icons/profile_image.png'), // Replace with profile image for this item
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          // Image or carousel section
          Container(
            height: 200, // Adjust height as needed
            // Removed border for the image area
            child: Center(
              child: Text(
                'Carousel of Images or Image with Audio',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 12),

          // Like, Comment, Share icons row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomIconButton(
                      icon: Icon(
                        Icons.favorite_border_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      onTap: () {
                        // Handle like action
                      },
                    ),
                    SizedBox(width: 18), // Increase gap between icons
                    CustomIconButton(
                      icon: Image.asset(
                        'lib/icons/chat.png',
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                      onTap: () {
                        // Handle comment action
                      },
                    ),
                    SizedBox(width: 18), // Increase gap between icons
                    CustomIconButton(
                      icon: Image.asset(
                        'lib/icons/share.png',
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                      onTap: () {
                        // Handle share action
                      },
                    ),
                  ],
                ),
                Image.asset(
                  'lib/icons/wishlist.png',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded; // Toggle the expanded state
                });
              },
              child: AnimatedSize(
                duration: Duration(milliseconds: 200),
                child: Text(
                  'This is a sample description. Tap to see more. ' * 4,
                  // Duplicate text for longer description
                  style: TextStyle(color: Colors.white),
                  maxLines: isExpanded ? null : 2,
                  // Show full text when expanded
                  overflow: isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),

          // Comments container
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: EdgeInsets.all(12), // Increased padding for more height
              decoration: BoxDecoration(
                color: Color(0xFFfc92dd),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User1: Top comment!',
                    style: TextStyle(
                      color: Color(0xFF2b1927),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'View all comments',
                    style: TextStyle(
                      color: Color(0xFF2b1927),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const CustomIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: icon,
    );
  }
}
