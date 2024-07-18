import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muiscprofileapp/pages/ChatPage.dart';
import 'package:muiscprofileapp/pages/Homepage.dart';
import 'package:muiscprofileapp/pages/NewScreen.dart';
import 'package:muiscprofileapp/pages/ProfileScreen.dart';
import 'package:muiscprofileapp/pages/SearchScreen.dart';
import 'package:muiscprofileapp/providers/BottomNavBarprovider.dart'; // Assuming you have a BottomNavigationBarProvider
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late PageController _pageController;
  int _selectedPageIndex = 0;

  TextEditingController _circlesSearchController = TextEditingController();
  TextEditingController _messagesSearchController = TextEditingController();
  bool _showCirclesSearchResults = false;
  bool _showMessagesSearchResults = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _circlesSearchController.dispose();
    _messagesSearchController.dispose();
    super.dispose();
  }

  void _onCirclesSearchTextChanged(String text) {
    setState(() {
      _showCirclesSearchResults = text.isNotEmpty;
    });
  }

  void _onMessagesSearchTextChanged(String text) {
    setState(() {
      _showMessagesSearchResults = text.isNotEmpty;
    });
  }

  void _onClearCirclesSearch() {
    _circlesSearchController.clear();
    setState(() {
      _showCirclesSearchResults = false;
    });
  }

  void _onClearMessagesSearch() {
    _messagesSearchController.clear();
    setState(() {
      _showMessagesSearchResults = false;
    });
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
      // Navigate to NewScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NewScreen()),
        );
        break;
      case 3:
      // Navigate to NotificationsScreen (current screen)
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121111), // Darker background color
              Color(0xFF121111), // Consistent color
            ],
            stops: [0.01, 0.1],
          ),
        ),
        child: Scaffold(
          backgroundColor: Color(0xFF121111), // Same background color as the gradient
          body: Column(
            children: [
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 60,
                color: Color(0xFFfc92de), // Light pink color
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(0,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Circles',
                            style: GoogleFonts.nunito(
                              color: _selectedPageIndex == 0
                                  ? Colors.black
                                  : Color.fromRGBO(128, 73, 111, 1), // Grey for unselected
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedPageIndex == 0)
                            Container(
                              height: 2,
                              width: 40, // Increase the width of the underline
                              color: Colors.black, // Underline color for selected
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(1,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Messages',
                            style: GoogleFonts.nunito(
                              color: _selectedPageIndex == 1
                                  ? Colors.black
                                  : Color.fromRGBO(128, 73, 111, 1), // Grey for unselected
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedPageIndex == 1)
                            Container(
                              height: 2,
                              width: 60, // Increase the width of the underline
                              color: Colors.black, // Underline color for selected
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedPageIndex = index;
                    });
                  },
                  children: [
                    // Circles Page
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                          controller: _circlesSearchController,
                                          style: TextStyle(color: Color(0xFF13001a)), // Text color
                                          decoration: InputDecoration(
                                            hintText: 'Songs, New Links, Posts, Circles & More..',
                                            hintStyle: TextStyle(color: Color(0xFF13001a).withOpacity(0.6)), // Hint text color
                                            border: InputBorder.none,
                                          ),
                                          onChanged: _onCirclesSearchTextChanged,
                                        ),
                                      ),
                                      if (_showCirclesSearchResults)
                                        IconButton(
                                          icon: Icon(Icons.clear, color: Color(0xFF13001a)),
                                          onPressed: _onClearCirclesSearch,
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
                                child: Image.asset('lib/icons/filter.png', height: 30, color: Colors.white), // Replace with your custom filter icon
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 5, // Replace with your actual number of groups
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage('lib/icons/group_image.png'), // Replace with your group image asset
                                  radius: 25,
                                ),
                                title: Text(
                                  'Group Name $index',
                                  style: GoogleFonts.nunito(color: Colors.white),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      'Updated $index min ago',
                                      style: GoogleFonts.nunito(color: Colors.white70),
                                    ),
                                  ],
                                ),
                                trailing: Icon(Icons.more_vert, color: Colors.white),
                                onTap: () {
                                  // Handle group tap
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    // Messages Page
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                          controller: _messagesSearchController,
                                          style: TextStyle(color: Color(0xFF13001a)), // Text color
                                          decoration: InputDecoration(
                                            hintText: 'Search Messages',
                                            hintStyle: TextStyle(color: Color(0xFF13001a).withOpacity(0.6)), // Hint text color
                                            border: InputBorder.none,
                                          ),
                                          onChanged: _onMessagesSearchTextChanged,
                                        ),
                                      ),
                                      if (_showMessagesSearchResults)
                                        IconButton(
                                          icon: Icon(Icons.clear, color: Color(0xFF13001a)),
                                          onPressed: _onClearMessagesSearch,
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
                                child: Image.asset('lib/icons/filter.png', height: 30, color: Colors.white), // Replace with your custom filter icon
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 5, // Replace with your actual number of messages
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage('lib/icons/profile_image.png'), // Replace with your profile image asset
                                  radius: 25,
                                ),
                                title: Text(
                                  'Username $index',
                                  style: GoogleFonts.nunito(color: Colors.white),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      '$index new messages',
                                      style: GoogleFonts.nunito(color: Colors.white70),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      '${index + 1} hrs ago',
                                      style: GoogleFonts.nunito(color: Colors.white70),
                                    ),
                                  ],
                                ),
                                trailing: Icon(Icons.more_vert, color: Colors.white),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatPage(title: 'Username $index',)));
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        backgroundColor: Colors.black,
        shape: CircleBorder(eccentricity: 1,side: BorderSide(color: Color.fromRGBO(255, 199, 238, 1),width: 3))
        ,child: Image.asset('lib/icons/link.png',color: Colors.white,height: 30,),


      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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