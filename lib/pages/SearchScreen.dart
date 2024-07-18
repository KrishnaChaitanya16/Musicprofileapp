import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:muiscprofileapp/pages/Homepage.dart';
import 'package:provider/provider.dart';
import 'package:muiscprofileapp/providers/BottomNavBarprovider.dart';
import 'package:muiscprofileapp/pages/NewScreen.dart';
import 'package:muiscprofileapp/pages/NotificationsScreen.dart';
import 'package:muiscprofileapp/pages/ProfileScreen.dart';
import 'package:muiscprofileapp/pages/SearchScreen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;

  List<String> _recentSearches = [
    'something',
    'something something',
    'The_RRR',
    'Monk the Mimmy',
    'RGv',
    'Cutipie',
    'gangbang005',
    'Music_debate'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _showSearchResults = text.isNotEmpty;
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _showSearchResults = false;
    });
  }

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
      // Navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
      // Do nothing as ExploreScreen is already on this tab
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
                stops: [0.01, 0.1],
              ),
            ),
          ),
          // Search container
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFc584b3), // Brighter shade of your chosen color
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Color(0xFF13001a)), // Icon color
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: Color(0xFF13001a)), // Text color
                            decoration: InputDecoration(
                              hintText: 'Songs, New Links, Posts, Circles & More..',
                              hintStyle: TextStyle(color: Color(0xFF13001a).withOpacity(0.6)), // Hint text color
                              border: InputBorder.none,
                            ),
                            onChanged: _onSearchTextChanged,
                          ),
                        ),
                        if (_showSearchResults)
                          IconButton(
                            icon: Icon(Icons.clear, color: Color(0xFF13001a)),
                            onPressed: _onClearSearch,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Image.asset('lib/icons/filter.png',height: 30,color: Colors.white ,), // Replace with your custom filter icon
                ),
              ],
            ),
          ),
          // Search results
          if (_showSearchResults)
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              bottom: 80, // Adjust the bottom inset as needed
              child: ListView.builder(
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.search, color: Colors.white),
                    title: Text(
                      _recentSearches[index],
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(Icons.clear, color: Colors.white),
                    onTap: () {
                      // Handle search item click
                    },
                  );
                },
              ),
            )
          else
          // Staggered Grid Items
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              bottom: 0, // Adjust the bottom inset as needed
              child: SingleChildScrollView(
                child: StaggeredGrid.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: List.generate(30, (index) {
                    int crossAxisCellCount;
                    int mainAxisCellCount;

                    if (index == 0 || index == 5 || index == 10) {
                      crossAxisCellCount = 2;
                      mainAxisCellCount = 1;
                    } else if (index == 1 || index == 11) {
                      crossAxisCellCount = 1;
                      mainAxisCellCount = 2;
                    } else {
                      crossAxisCellCount = 1;
                      mainAxisCellCount = 1;
                    }

                    return StaggeredGridTile.count(
                      crossAxisCellCount: crossAxisCellCount,
                      mainAxisCellCount: mainAxisCellCount,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
                        child: Container(
                          color: Colors.primaries[index % Colors.primaries.length],
                          child: Center(
                            child: Text(
                              'Item $index',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        selectedItemColor: Colors.white,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onTabTapped,
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
