import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String formatTimeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);

    if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inHours > 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours == 1) {
      return '1 hour ago';
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes == 1) {
      return '1 minute ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _circlesSearchController.dispose();
    _messagesSearchController.dispose();
    super.dispose();
  }
  Future<void> updateUnreadCount(String circleId, int incrementBy) async {
    try {
      final circleRef = FirebaseFirestore.instance.collection('circles').doc(circleId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final circleDoc = await transaction.get(circleRef);
        if (!circleDoc.exists) {
          throw Exception('Circle does not exist');
        }

        final currentUnreadCount = circleDoc['unreadCount'] as int? ?? 0;
        transaction.update(circleRef, {
          'unreadCount': currentUnreadCount + incrementBy,
          'timestamp': Timestamp.now(),
        });
      });
    } catch (e) {
      print('Error updating unread count: $e');
    }
  }
  Future<void> updateLastMessage(String circleId, String message) async {
    try {
      final circleRef = FirebaseFirestore.instance.collection('circles').doc(circleId);

      await circleRef.update({
        'lastMessage': message,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating last message: $e');
    }
  }
  Future<void> resetUnreadCount(String circleId) async {
    try {
      final circleRef = FirebaseFirestore.instance.collection('circles').doc(circleId);

      await circleRef.update({
        'unreadCount': 0,
      });
    } catch (e) {
      print('Error resetting unread count: $e');
    }
  }

  Future<String?> fetchUsername(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        print(data?['username'] as String?);
        return data?['username'] as String?;
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
    return null;
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
  Future<List<Map<String, dynamic>>> fetchMessages(String userId) async {
    try {
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('receiverId', isEqualTo: await fetchUsername(userId))
          .get();

      return messagesSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;



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
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('circles').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Center(child: Text('No circles available', style: TextStyle(color: Colors.white)));
                              }

                              final circles = snapshot.data!.docs;

                              // Process circles and sort by unreadCount if needed
                              final sortedCircles = circles.map((doc) {
                                final circle = doc.data() as Map<String, dynamic>;
                                return {
                                  'circleId': circle['circleId'],
                                  'name': circle['name'],
                                  'description': circle['description'],
                                  'imageUrl': circle['imageUrl'],
                                  'unreadCount': circle['unreadCount'] ?? 0,
                                  'lastMessage': circle['lastMessage'],
                                  'timestamp': circle['timestamp'] as Timestamp,
                                };
                              }).toList()
                                ..sort((a, b) {
                                  final unreadCountA = a['unreadCount'] as int?;
                                  final unreadCountB = b['unreadCount'] as int?;
                                  return (unreadCountB ?? 0).compareTo(unreadCountA ?? 0); // Unread circles first
                                });

                              return ListView.builder(
                                itemCount: sortedCircles.length,
                                itemBuilder: (context, index) {
                                  final circle = sortedCircles[index];
                                  final name = circle['name'] as String;
                                  final description = circle['description'] as String;
                                  final imageUrl = circle['imageUrl'] as String;
                                  final unreadCount = circle['unreadCount'] as int;
                                  final lastMessage = circle['lastMessage'] as String?;
                                  final timestamp = circle['timestamp'] as Timestamp;

                                  return ListTile(
                                    contentPadding: EdgeInsets.all(8),
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(imageUrl),
                                    ),
                                    title: Text(name, style: TextStyle(color: Colors.white)),
                                    subtitle: RichText(
                                      text: TextSpan(
                                        children: [
                                          if (unreadCount > 0)
                                            TextSpan(
                                              text: '$unreadCount New message${unreadCount > 1 ? 's' : ''} ',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          TextSpan(
                                            text: ' ${lastMessage ?? ''} ',
                                            style: TextStyle(color: Colors.grey[400]),
                                          ),
                                          TextSpan(
                                            text: ' ${formatTimeAgo(timestamp)} ',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                          if (unreadCount > 0)
                                            WidgetSpan(
                                              child: CircleAvatar(
                                                radius: 4,
                                                backgroundColor: Color(0xFFF78FD8), // RGB(247, 143, 218)
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(chatId: name,),
                                        ),
                                      );
                                    },
                                  );
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
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('chats').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Center(child: Text('No messages available', style: TextStyle(color: Colors.white)));
                              }

                              // Extract conversations
                              final conversations = snapshot.data!.docs.map((chatDoc) {
                                final messages = chatDoc['messages'] as List<dynamic>? ?? [];

                                // Get the latest message
                                final latestMessage = messages.isNotEmpty ? messages.last : {};

                                final senderId = latestMessage['senderId'] as String? ?? 'Unknown';
                                final messageText = latestMessage['message'] as String? ?? '';
                                final timestamp = latestMessage['timestamp'] as Timestamp?;
                                final imageUrl = latestMessage['imageUrl'] as String? ?? '';
                                final read = latestMessage['read'] as bool? ?? false;

                                // Document ID represents the chat between sender and receiver
                                final chatId = chatDoc.id;
                                final participants = chatId.split('-');

                                // Extract sender and receiver IDs
                                final otherParticipantId = participants.firstWhere(
                                        (id) => id != currentUserId,
                                    orElse: () => 'Unknown'
                                );

                                return {
                                  'chatId': chatId,
                                  'chatPartnerId': otherParticipantId,
                                  'lastMessage': messageText,
                                  'timestamp': timestamp,
                                  'imageUrl': imageUrl,
                                };
                              }).toList();

                              return ListView.builder(
                                itemCount: conversations.length,
                                itemBuilder: (context, index) {
                                  final conversation = conversations[index];
                                  final chatId = conversation['chatId'] as String;
                                  final chatPartnerId = conversation['chatPartnerId'] as String;
                                  final lastMessage = conversation['lastMessage'] as String;
                                  final timestamp = conversation['timestamp'] as Timestamp?;
                                  final imageUrl = conversation['imageUrl'] as String;

                                  return ListTile(
                                    contentPadding: EdgeInsets.all(8),
                                    leading: CircleAvatar(
                                      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                                      child: imageUrl.isEmpty ? Icon(Icons.person) : null,
                                    ),
                                    title: Text(chatPartnerId, style: TextStyle(color: Colors.white)),
                                    subtitle: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${lastMessage ?? ''} ',
                                            style: TextStyle(color: Colors.grey[400]),
                                          ),
                                          TextSpan(
                                            text: timestamp != null ? ' ${formatTimeAgo(timestamp)} ' : '',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                            chatId: chatId, // Pass the unique chat document ID
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        )


                      ],
          ),
    ]),
      ),]),
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
    )));
  }
}