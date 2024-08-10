import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muiscprofileapp/pages/ActivityPage.dart';
import 'package:muiscprofileapp/pages/JammingPage.dart';
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
  bool isExpanded = false; // State to manage expanded description

  // Function to handle bottom navigation bar taps
  void _onTabTapped(int index) {
    final navigationProvider = Provider.of<BottomNavigationBarProvider>(
      context,
      listen: false,
    );

    // Do nothing if already on the same tab
    if (navigationProvider.currentIndex == index) {
      return;
    }

    // Update current index in provider
    navigationProvider.setIndex(index);

    // Perform navigation based on index
    switch (index) {
      case 0:
      // Navigate to HomePage
        break; // No need to navigate to HomePage again
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
              // Top bar with icons and text
              Container(
                padding: EdgeInsets.fromLTRB(16, 50, 16, 16),
                child: Row(
                  children: [
                    // Leftmost End
                    Row(
                      children: [
                        Image.asset(
                          'lib/icons/music.png', // Ensure this path is correct
                          width: 28,
                          height: 28,
                          color: Colors.white, // Adjust color as needed
                        ),
                        SizedBox(width: 8),
                        Text(
                          'SymJam',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 16), // Space between the SymJam text and notifications icon
                      ],
                    ),
                    Spacer(), // This pushes the remaining widgets to the rightmost end
                    // Notifications icon
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityPage()));
                      },
                      child: Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    // 'Jam' button
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => JammingScreen()));
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('lib/icons/hotspot.png'),
                                  fit: BoxFit.cover,
                                ),
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
                )

              ),
              // Divider
              Divider(
                color: Colors.white.withOpacity(0.3),
                thickness: 1,
                height: 1,
              ),
              // Expanded list of items
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    // Data snapshot is ready
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // Get the document snapshot at the current index
                        QueryDocumentSnapshot<Object?> document = snapshot.data!
                            .docs[index];
                        return _buildListItem(document as DocumentSnapshot<
                            Map<String, dynamic>>);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Bottom navigation bar
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
                // Home icon
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'lib/icons/home.png',
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  label: 'Home',
                ),
                // Explore icon
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'lib/icons/orbits.png',
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  label: 'Explore',
                ),
                // New icon
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'lib/icons/more.png',
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  label: 'New',
                ),
                // Inbox icon
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'lib/icons/inbox.png',
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  label: 'Inbox',
                ),
                // Profile icon
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
          ),
        ],
      ),
    );
  }

  // Function to build each list item
  Widget _buildListItem(DocumentSnapshot<Map<String, dynamic>> document) {
    final Map<String, dynamic> data = document.data()!;
    final String username = data['username'] ?? 'Username';
    final String description = data['description'] ?? 'Sample description';
    final List<dynamic> files = data['files'] ?? [];
    int likes = data['likes'] ?? 0;
    List<dynamic> comments = data['comments'] ?? [];

    // Comment controller for handling new comments
    TextEditingController _commentController = TextEditingController();

    // Dispose method for disposing the comment controller
    void disposeCommentController() {
      _commentController.dispose();
    }

    // Sort comments by timestamp to ensure the latest comment is displayed first
    comments.sort((a, b) {
      Timestamp timestampA = a['timestamp'];
      Timestamp timestampB = b['timestamp'];
      return timestampB.compareTo(timestampA);
    });

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0),
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
                // User profile image
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
                  child: FutureBuilder<String?>(
                    future: _fetchProfileImageUrl(), // Fetch the profile image URL
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(), // Loading indicator
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey, // Fallback color
                          backgroundImage: AssetImage('lib/icons/profile_image.png'), // Fallback image
                        );
                      }
                      final imageUrl = snapshot.data!;
                      return CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(imageUrl), // Use the fetched image URL
                      );
                    },
                  ),
                ),

                SizedBox(width: 12),
                // Username text
                Expanded(
                  child: Text(
                    username,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // More options icon
                Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          // Image section
          if (files.isNotEmpty && files[0] is String) ...{
            Container(
              height: 350, // Adjust height as needed
              child: Image.network(
                files[0], // Use the URL directly from Firestore
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text('Error loading image'),
                  );
                },
              ),
            ),
          },
          SizedBox(height: 12),

          // Like, Comment, Share icons row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Like icon
                CustomIconButton(
                  icon: Icon(
                    Icons.favorite_border_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  onTap: () {
                    // Increment likes locally
                    likes++;

                    // Retrieve the URL of the post image from the files array
                    final files = document['files'] as List<dynamic>? ?? [];
                    final postImage = files.isNotEmpty ? files[0] : ''; // Assuming the first file is the post image

                    // Update Firestore with new likes count
                    FirebaseFirestore.instance
                        .collection('posts')
                        .doc(document.id)
                        .update({'likes': likes})
                        .then((_) {
                      print('Likes updated successfully');

                      // Log the activity in the activities collection
                      FirebaseFirestore.instance.collection('activities').add({
                        'type': 'like',
                        'description': 'User liked your post',
                        'postImage': postImage, // Use the retrieved post image URL
                        'timestamp': FieldValue.serverTimestamp(),
                        'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
                        'relatedPostId': document.id,
                      }).then((_) {
                        print('Activity logged successfully');
                      }).catchError((error) {
                        print('Failed to log activity: $error');
                      });
                    })
                        .catchError((error) {
                      print('Failed to update likes: $error');
                    });

                    setState(() {}); // Refresh UI
                  },


                ),
                SizedBox(width: 15), // Decrease gap between icons
                // Comment icon with comments sheet opening
                CustomIconButton(
                  icon: Image.asset(
                    'lib/icons/chat.png',
                    height: 24,
                    color: Colors.white,
                  ),
                  onTap: () {
                    // Open comments sheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, // Full height sheet
                      backgroundColor:
                      Colors.transparent, // Transparent background
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return SingleChildScrollView(
                              child: Container(
                                height: MediaQuery
                                    .of(context)
                                    .size
                                    .height *
                                    0.8, // Adjust as needed
                                decoration: BoxDecoration(
                                  color: Color(0xFF1f0221), // Bottom sheet background color
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Header with close button
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Comments',
                                            style: TextStyle(
                                              color: Colors.white, // Header text color
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close,
                                                color: Colors.white),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),

                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: comments.length,
                                        itemBuilder: (context, index) {
                                          final Map<String, dynamic> comment = comments[index];
                                          final String commentUserId = comment['username'] ?? '';
                                          final String commentText = comment['comment'] ?? '';
                                          final int commentLikes = comment['likes'] ?? 0;

                                          return FutureBuilder<DocumentSnapshot>(
                                            future: FirebaseFirestore.instance.collection('users').doc(commentUserId).get(),
                                            builder: (context, userSnapshot) {
                                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                                return Center(child: CircularProgressIndicator());
                                              }

                                              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                                return SizedBox(); // Handle case where user data does not exist
                                              }

                                              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                              final String commentUsername = userData['username'] ?? 'Username';
                                              final String profilePicUrl = userData['imageUrl'] ?? 'assets/default_profile_pic.png';

                                              return Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // User profile image
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage: NetworkImage(profilePicUrl),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    // Comment text and like section
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            commentUsername,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            commentText,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                        ],
                                                      ),
                                                    ),
                                                    // Like button and count
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.favorite_border_outlined,
                                                            color: Colors.white,
                                                          ),
                                                          onPressed: () async {
                                                            final userId = FirebaseAuth.instance.currentUser?.uid;
                                                            if (userId == null) {
                                                              print('User ID is null');
                                                              return;
                                                            }

                                                            // Increment the like count locally
                                                            final newLikeCount = commentLikes + 1;
                                                            comment['likes'] = newLikeCount;

                                                            try {
                                                              // Update Firestore with the new like count
                                                              await FirebaseFirestore.instance.collection('posts').doc(document.id).update({
                                                                'comments': comments,
                                                              });

                                                              print('Comment liked successfully');

                                                              // Fetch the post document to retrieve the post image
                                                              final postDoc = await FirebaseFirestore.instance.collection('posts').doc(document.id).get();
                                                              if (!postDoc.exists) {
                                                                print('Post document does not exist');
                                                                return;
                                                              }

                                                              final postData = postDoc.data()!;
                                                              final List<dynamic> files = List.from(postData['files'] ?? []);
                                                              final postImage = files.isNotEmpty ? files[0] as String : ''; // Get the first file URL

                                                              // Fetch the user's profile picture URL
                                                              final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
                                                              if (!userDoc.exists) {
                                                                print('User document does not exist');
                                                                return;
                                                              }

                                                              final userData = userDoc.data()!;
                                                              final profilePic = userData['profilePic'] ?? 'assets/default_profile_pic.png'; // Default profile picture URL

                                                              // Prepare activity data
                                                              final now = DateTime.now();
                                                              final activityData = {
                                                                'userId': userId,
                                                                'type': 'like',
                                                                'description': 'Liked your comment on post ${document.id}',
                                                                'timestamp': Timestamp.fromDate(now),
                                                                'profilePic': profilePic, // Use the fetched profile picture URL
                                                                'postImage': postImage, // Use the fetched post image URL
                                                              };

                                                              // Record activity in Firestore
                                                              await FirebaseFirestore.instance.collection('activities').add(activityData);

                                                              print('Activity recorded successfully');
                                                            } catch (error) {
                                                              print('Failed to like comment or record activity: $error');
                                                            }

                                                            setState(() {}); // Refresh UI
                                                          },
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          '$commentLikes',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),

                                    // Add comment section
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // User profile image
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundImage: AssetImage(
                                                  'lib/icons/profile_image.png'),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          // Comment input field
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                hintText: 'Add a comment...',
                                                hintStyle:
                                                TextStyle(color: Colors.white),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(20),
                                                  borderSide: BorderSide(
                                                      color: Colors.white),
                                                ),
                                                filled: true,
                                                fillColor: Color(0xFF1e021f), // Input field background color
                                              ),
                                              controller: _commentController,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          IconButton(
                                            icon: Icon(Icons.send,
                                                color: Colors.white),
                                            onPressed: () {
                                              // Add comment to Firestore
                                              final Map<String, dynamic> newComment = {
                                                'username': username,
                                                'comment': _commentController.text.trim(),
                                                'timestamp': Timestamp.now(),
                                                'likes': 0, // Default like count
                                              };
                                              comments.add(newComment); // Add locally
                                              // Update Firestore
                                              FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .doc(document.id)
                                                  .update({'comments': comments})
                                                  .then((value) => print('Comment added successfully'))
                                                  .catchError((error) => print('Failed to add comment: $error'));
                                              _commentController.clear(); // Clear input
                                              // Update UI
                                              setState(() {});
                                            },
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                SizedBox(width: 15), // Decrease gap between icons
                // Share icon
                CustomIconButton(
                  icon: Image.asset(
                    'lib/icons/share.png',
                    height: 24,
                    color: Colors.white,
                  ),
                  onTap: () {
                    // Handle share action
                  },
                ),
                SizedBox(width: 262,),
                IconButton(
                  onPressed: () async {
                    try {
                      // Get the current logged-in user
                      final user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        final currentUserId = user.uid;

                        // Reference to the user's document in Firestore
                        final firestore = FirebaseFirestore.instance;
                        final userDocRef = firestore.collection('users').doc(currentUserId);

                        // Add the post ID to the user's saved posts
                        await userDocRef.update({
                          'savedPosts': FieldValue.arrayUnion([document.id])
                        });

                        // Optionally, show a success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Post saved successfully!')),
                        );
                      } else {
                        // Handle case where user is not logged in
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please log in to save posts.')),
                        );
                      }
                    } catch (e) {
                      // Handle errors
                      print('Failed to save post: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save post.')),
                      );
                    }
                  },
                  icon: Image.asset(
                    'lib/icons/wishlist.png',
                    height: 24,
                    color: Colors.white,
                  ),
                )

              ],
            ),
          ),
          SizedBox(height: 8),

          // Likes count text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$likes likes',
              style: TextStyle(
                color: Color(0xFFfc92de), // Text color for likes count
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 8),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 8),

          // Comments container
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
                  // Display top comment if available
                  if (comments.isNotEmpty) ...{
                    Text(
                      '${comments.first['username']}: ${comments.first['comment']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                  },
                  // Display "View all comments" if there are more than one comment
                  if (comments.length > 1) ...{
                    GestureDetector(
                      onTap: () {
                        // Open the comments sheet
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // Full height sheet
                          backgroundColor: Colors.transparent, // Transparent background
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return SingleChildScrollView(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.8, // Adjust as needed
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1f0221), // Bottom sheet background color
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        // Header with close button
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Comments',
                                                style: TextStyle(
                                                  color: Colors.white, // Header text color
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.close, color: Colors.white),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: comments.length,
                                            itemBuilder: (context, index) {
                                              final Map<String, dynamic> comment = comments[index];
                                              final String commentUsername = comment['username'] ?? 'Username';
                                              final String commentText = comment['comment'] ?? '';
                                              final int commentLikes = comment['likes'] ?? 0;

                                              return Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // User profile image
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage: AssetImage('lib/icons/profile_image.png'),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    // Comment text and like section
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            commentUsername,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            commentText,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                        ],
                                                      ),
                                                    ),
                                                    // Like button and count
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.favorite_border_outlined,
                                                            color: Colors.white,
                                                          ),
                                                          onPressed: () {
                                                            // Handle comment like action
                                                            final newLikeCount = commentLikes + 1;
                                                            comment['likes'] = newLikeCount;
                                                            // Update Firestore
                                                            FirebaseFirestore.instance
                                                                .collection('posts')
                                                                .doc(document.id)
                                                                .update({
                                                              'comments': comments
                                                            }).then((value) =>
                                                                print('Comment liked successfully'))
                                                                .catchError((error) =>
                                                                print('Failed to like comment: $error'));
                                                            setState(() {}); // Refresh UI
                                                          },
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          '$commentLikes',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        // Add comment section
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              // User profile image
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: AssetImage('lib/icons/profile_image.png'),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              // Comment input field
                                              Expanded(
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    hintText: 'Add a comment...',
                                                    hintStyle: TextStyle(color: Colors.white),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                      borderSide: BorderSide(color: Colors.white),
                                                    ),
                                                    filled: true,
                                                    fillColor: Color(0xFF1e021f), // Input field background color
                                                  ),
                                                  controller: _commentController,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              IconButton(
                                                icon: Icon(Icons.send, color: Colors.white),
                                                onPressed: () {
                                                  // Add comment to Firestore
                                                  final Map<String, dynamic> newComment = {
                                                    'username': username,
                                                    'comment': _commentController.text.trim(),
                                                    'timestamp': Timestamp.now(),
                                                    'likes': 0, // Default like count
                                                  };
                                                  comments.add(newComment); // Add locally
                                                  // Update Firestore
                                                  FirebaseFirestore.instance
                                                      .collection('posts')
                                                      .doc(document.id)
                                                      .update({'comments': comments})
                                                      .then((value) => print('Comment added successfully'))
                                                      .catchError((error) => print('Failed to add comment: $error'));
                                                  _commentController.clear(); // Clear input
                                                  // Update UI
                                                  setState(() {});
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Text(
                        'View all comments',
                        style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold),
                      ),
                    ),
                  },
                ],
              ),
            ),
          ),

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
