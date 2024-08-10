
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muiscprofileapp/pages/EditProfile.dart';
import 'package:muiscprofileapp/pages/Homepage.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muiscprofileapp/pages/Homepage.dart';

class ProfileScreen extends StatelessWidget {
  final bool isOwnProfile;

  const ProfileScreen({
    Key? key,
    this.isOwnProfile = true,
  }) : super(key: key);

  Future<String?> _getCurrentUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return user?.uid;
    } catch (e) {
      print('Error fetching user ID: $e');
      return null;
    }
  }
  Future<void> _sendLinkRequest(String recipientUserId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        print('User not logged in.');
        return;
      }

      // Reference to the activities collection of the recipient user
      final activitiesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(recipientUserId)
          .collection('activities');

      // Add a new activity to the activities collection
      await activitiesRef.add({
        'type': 'link_request',
        'fromUserId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Link request sent successfully.');
    } catch (e) {
      print('Error sending link request: $e');
    }
  }

  Future<List<String>> fetchSkills() async {
    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user is currently logged in.');
        return [];
      }

      // Fetch the user document from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final skills = userData?['skills'] as List<dynamic>? ?? [];
        return skills.map((skill) => skill.toString()).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching skills: $e');
      return [];
    }
  }
  Future<List<DocumentSnapshot>> _fetchUserPosts() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return [];
      }

      final postsQuery = await FirebaseFirestore.instance
          .collection('posts')
          .where('username', isEqualTo: await _fetchCurrentUserUsername())
          .get();

      return postsQuery.docs;
    } catch (e) {
      print('Error fetching user posts: $e');
      return [];
    }
  }

  Future<String?> _fetchCurrentUserUsername() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return null;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['username'];
      }
      return null;
    } catch (e) {
      print('Error fetching current user username: $e');
      return null;
    }
  }
  Future<List<DocumentSnapshot>> _fetchUserSongs() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('User ID is null');
        return [];
      }

      // Adjust the collection path and query as needed
      final querySnapshot = await FirebaseFirestore.instance
          .collection('songs')
           // Use 'username' if you store usernames instead of userIds
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching user songs: $e');
      return [];
    }
  }







  Future<int> _fetchLinksCount(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['nooflinks'] ?? 0; // Assume nooflinks is a field in your users collection
      }
      return 0;
    } catch (e) {
      print('Error fetching links count: $e');
      return 0;
    }
  }
  Future<void> _playSong(String songUrl) async {
    final AudioPlayer _audioPlayer = AudioPlayer();

    try {
      // Load and play the song
      await _audioPlayer.setUrl(songUrl);
      _audioPlayer.play();

      // Optionally check if the playback started successfully
      if (_audioPlayer.playing) {
        print('Playback started');
      }

      // Listen for state changes
      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.playing) {
          print('Playing song');
        } else if (playerState.processingState == ProcessingState.completed) {
          print('Playback completed');
        } else if (playerState.processingState == ProcessingState.idle) {
          print('Player is idle');
        }
      });

    } catch (e) {
      print('Error playing song: $e');
    }
  }
  Future<String?> _fetchProfileImageUrl() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID
      if (userId == null) return null;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['imageUrl']; // Fetch the direct download URL from Firestore
      }
      return null;
    } catch (e) {
      print('Error fetching profile image URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getCurrentUserId(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userSnapshot.hasError || !userSnapshot.hasData) {
          return Scaffold(
            body: Center(child: Text('Error fetching user data')),
          );
        }

        final userId = userSnapshot.data!;

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
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            'Loading...',
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Text(
                            'Error loading profile',
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        final userData = snapshot.data?.data() as Map<String, dynamic>;
                        return Column(
                          children: [
                            Text(
                              userData?['username'] ?? 'Username', // Replace with actual username
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              userData?['name'] ?? 'Full Name', // Replace with actual full name
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    FutureBuilder<int>(
                      future: _fetchLinksCount(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            'Loading links...',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'Error fetching links',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          );
                        }
                        return Text(
                          '${snapshot.data} Links',
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 30),
                    if (isOwnProfile) // Show the Edit Profile button only if it's the current user's profile
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfile()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(184, 55, 134, 1), // Keep the original color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25), // Keep the original border radius
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Keep the original padding
                        ),
                        icon: Icon(Icons.edit, color: Colors.white), // Keep the original icon color
                        label: Text(
                          'Edit Profile',
                          style: GoogleFonts.nunito(
                            fontSize: 16, // Keep the original font size
                            color: Colors.white, // Keep the original font color
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
                    FutureBuilder<List<DocumentSnapshot>>(
                      future: _fetchUserPosts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 120,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return Container(
                            height: 120,
                            child: Center(child: Text('Error loading posts')),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            height: 120,
                            child: Center(child: Text('No posts available')),
                          );
                        }

                        final posts = snapshot.data!;
                        return Container(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index].data() as Map<String, dynamic>;
                              final files = post['files'] as List<dynamic>? ?? [];

                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                width: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: files.length,
                                  itemBuilder: (context, fileIndex) {
                                    final fileUrl = files[fileIndex];
                                    return Container(
                                      margin: EdgeInsets.symmetric(horizontal: 4),
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white.withOpacity(0.2),
                                        image: DecorationImage(
                                          image: NetworkImage(fileUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )


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
                    FutureBuilder<List<DocumentSnapshot>>(
                      future: _fetchUserSongs(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 120,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return Container(
                            height: 120,
                            child: Center(child: Text('Error loading songs')),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            height: 120,
                            child: Center(child: Text('No songs available')),
                          );
                        }

                        final songs = snapshot.data!;

                        return Container(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index].data() as Map<String, dynamic>;

                              final posterUrl = song['poster'] as String? ?? '';
                              final title = song['title'] as String? ?? 'Unknown Title';
                              final songUrl = song['songUrl'] as String? ?? '';

                              return GestureDetector(
                                onTap: () {
                                  if (songUrl.isNotEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SongDialog(
                                          songUrl: songUrl,
                                          posterUrl: posterUrl,
                                          title: title,
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  width: 100,
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundImage: posterUrl.isNotEmpty
                                            ? NetworkImage(posterUrl)
                                            : AssetImage('assets/default_poster.png') as ImageProvider, // Default poster image
                                      ),
                                      SizedBox(height: 8),
                                      Flexible(
                                        child: Text(
                                          title,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12, // Adjust as needed
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )

                  ],
                ),
              )

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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
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
                icon: FutureBuilder<String?>(
                  future: _fetchProfileImageUrl(), // Assuming this returns the direct download URL
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(), // Loading indicator
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return CircleAvatar(
                        radius: 12, // Adjust radius to fit the size
                        backgroundColor: Colors.grey, // Fallback color
                        backgroundImage: AssetImage('lib/icons/default_profile.png'), // Fallback image
                      );
                    }
                    final imageUrl = snapshot.data!;
                    return CircleAvatar(
                      radius: 19, // Adjust radius to fit the size
                      backgroundImage: NetworkImage(imageUrl),
                      onBackgroundImageError: (exception, stackTrace) {
                        print('Error loading image: $exception'); // Log error if any
                      },
                      child: imageUrl == null
                          ? Icon(Icons.person, size: 24) // Placeholder icon if image URL is null
                          : null,
                    );

                  },
                ),
                label: 'Profile',
              )


            ],
          ),
        );
      },
    );
  }
}


Future<String?> getPublicImageUrl(String path) async {
  try {
    final storageRef = FirebaseStorage.instance.ref().child(path);
    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  } catch (e) {
    print('Error getting image URL: $e');
    return null;
  }
}
class ProfileAvatar extends StatelessWidget {
  Future<String?> _fetchProfileImageUrl() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID
      if (userId == null) return null;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['imageUrl']; // Fetch the direct download URL from Firestore
      }
      return null;
    } catch (e) {
      print('Error fetching profile image URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _fetchProfileImageUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Loading profile image...');
          return CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: CircularProgressIndicator(), // Loading indicator
          );
        }
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/profile_avatar.png'), // Fallback image
            backgroundColor: Colors.white,
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('No data found, using fallback image.');
          return CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/profile_avatar.png'), // Fallback image
            backgroundColor: Colors.white,
          );
        }
        final imageUrl = snapshot.data!;
        print('Profile image URL: $imageUrl');
        return CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(imageUrl),
          backgroundColor: Colors.white,
        );
      },
    );
  }
}
class SongDialog extends StatefulWidget {
  final String songUrl;
  final String posterUrl;
  final String title;

  const SongDialog({
    Key? key,
    required this.songUrl,
    required this.posterUrl,
    required this.title,
  }) : super(key: key);

  @override
  _SongDialogState createState() => _SongDialogState();
}

class _SongDialogState extends State<SongDialog> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Background color
          Container(
            color: Colors.black.withOpacity(0.7),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Song poster
                widget.posterUrl.isNotEmpty
                    ? Image.network(widget.posterUrl, height: 150, fit: BoxFit.cover)
                    : Image.asset('assets/default_poster.png', height: 150, fit: BoxFit.cover),
                SizedBox(height: 10),
                Text(
                  widget.title,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(height: 20),
                // Icon buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Play button
                    IconButton(
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      onPressed: () async {
                        try {
                          // Stop any ongoing playback before starting a new one
                          _audioPlayer.stop();
                          await _audioPlayer.setUrl(widget.songUrl);
                          _audioPlayer.play();
                        } catch (e) {
                          print('Error playing song: $e');
                        }
                      },
                    ),
                    SizedBox(width: 20),
                    // Pause button
                    IconButton(
                      icon: Icon(Icons.pause, color: Colors.white),
                      onPressed: () {
                        _audioPlayer.pause();
                      },
                    ),
                    SizedBox(width: 20),
                    // Close button
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
