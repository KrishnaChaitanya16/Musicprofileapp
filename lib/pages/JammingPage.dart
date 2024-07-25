import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JammingScreen extends StatefulWidget {
  @override
  _JammingScreenState createState() => _JammingScreenState();
}

class _JammingScreenState extends State<JammingScreen> {
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

  void _onTabTapped(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
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
                    onTap: () => _onTabTapped(0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Join',
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
                            width: 40, // Underline width
                            color: Colors.black, // Underline color for selected
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _onTabTapped(1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Review',
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
                            width: 60, // Underline width
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
                  // Join Page
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
                                  color: Color(0xFFc584b3), // Brighter shade
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, color: Color(0xFF13001a)), // Icon color
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: TextField(
                                        style: TextStyle(color: Color(0xFF13001a)),
                                        decoration: InputDecoration(
                                          hintText: 'Search Jams...',
                                          hintStyle: TextStyle(color: Color(0xFF13001a).withOpacity(0.6)),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            Container(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 5, // Number of ongoing jams
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 150,
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFc584b3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Ongoing Jam $index',
                                        style: GoogleFonts.nunito(color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Completed Jams',
                                style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: 5, // Number of completed jams
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF8f286d), // Background color for completed jams
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(8),
                                    leading: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: AssetImage('assets/thumbnail.jpg'), // Placeholder thumbnail
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      'Completed Jam $index',
                                      style: GoogleFonts.nunito(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      'Creator Username',
                                      style: GoogleFonts.nunito(color: Colors.white),
                                    ),
                                    trailing: TextButton(
                                      onPressed: () {
                                        // Handle view recorded action
                                      },
                                      child: Text(
                                        'View Recorded',
                                        style: GoogleFonts.nunito(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Review Page
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
                                  color: Color(0xFFc584b3), // Brighter shade
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, color: Color(0xFF13001a)), // Icon color
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: TextField(
                                        style: TextStyle(color: Color(0xFF13001a)),
                                        decoration: InputDecoration(
                                          hintText: 'Search Reviews...',
                                          hintStyle: TextStyle(color: Color(0xFF13001a).withOpacity(0.6)),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('scheduled_jams').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(child: Text('No scheduled jams available'));
                            }

                            final jams = snapshot.data!.docs;

                            return ListView(
                              children: [
                                Container(
                                  height: 250, // Height for the horizontal list view
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: jams.length,
                                    itemBuilder: (context, index) {
                                      final jam = jams[index].data() as Map<String, dynamic>;
                                      final jamTitle = jam['title'] ?? 'No Title';
                                      final jamThumbnail = jam['fileUrl'] ?? 'assets/placeholder_image.jpg';

                                      return Container(
                                        width: 200,
                                        margin: EdgeInsets.all(8),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            // Network image or placeholder image
                                            Image.network(
                                              jamThumbnail,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/placeholder_image.jpg',
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                            // Overlay with jam title
                                            Container(
                                              color: Colors.black54,
                                              child: Center(
                                                child: Text(
                                                  jamTitle,
                                                  style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Recent Reviews',
                                    style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: jams.length,
                                  itemBuilder: (context, index) {
                                    final jam = jams[index].data() as Map<String, dynamic>;
                                    final jamTitle = jam['title'] ?? 'No Title';
                                    final jamThumbnail = jam['fileUrl'] ?? 'assets/placeholder_image.jpg';

                                    return Container(
                                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF8f286d),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(8),
                                        leading: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius: BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: NetworkImage(jamThumbnail),
                                              onError: (error, stackTrace) {

                                              },
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          jamTitle,
                                          style: GoogleFonts.nunito(color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          'Creator Username',
                                          style: GoogleFonts.nunito(color: Colors.white),
                                        ),
                                        trailing: TextButton(
                                          onPressed: () {
                                            // Handle view recorded action
                                          },
                                          child: Text(
                                            'View Recorded',
                                            style: GoogleFonts.nunito(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
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
    );
  }
}
