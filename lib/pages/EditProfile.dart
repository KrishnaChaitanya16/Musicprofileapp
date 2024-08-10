import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:file_picker/file_picker.dart'; // Import File Picker
import 'dart:io'; // Import for File class

// Predefined map for skill image paths
final Map<String, String> skillImages = {
  'Songwriting': 'assets/songwriting.jpeg',
  'Vocals': 'assets/vocals.jpg',
  'Flute': 'assets/flute.jpg',
  'Drums': 'assets/drums.jpeg',
  'Veena': 'assets/veena.jpeg',
  'Tabla': 'assets/tabala.jpeg',
  // Add more skills and their image paths here
};

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? _profileImage;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _bioController = TextEditingController(); // Controller for bio
  List<String> _favoriteSkills = []; // List to store favorite skills
  List<Map<String, String>> _allSkills = [];
  List<String> _favoriteGenres = [];// List to store all skills

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchFavoriteSkills(); // Fetch favorite skills
    _fetchSkillsData();
    _fetchFavoriteGenres();// Fetch all skills
  }
  final List<Map<String, String>> genreData = [
    {'imagePath': 'assets/indian.jpeg', 'genreName': 'Indian Classic'},
    {'imagePath': 'assets/western.jpeg', 'genreName': 'Western Classic'},
    {'imagePath': 'assets/pop.jpeg', 'genreName': 'Pop'},
    {'imagePath': 'assets/rock.jpeg', 'genreName': 'Rock'},
    {'imagePath': 'assets/jazz_cleanup.jpeg', 'genreName': 'Jazz'},
    {'imagePath': 'assets/blues.jpeg', 'genreName': 'Blues'},
    {'imagePath': 'assets/hiphop.jpeg', 'genreName': 'Hip Hop'},
    {'imagePath': 'assets/electro.jpeg', 'genreName': 'Electro'},
    {'imagePath': 'assets/flock.jpg', 'genreName': 'Flockk'},
    {'imagePath': 'assets/ghazal.jpeg', 'genreName': 'Ghazal'},
    {'imagePath': 'assets/devotional.jpeg', 'genreName': 'Devotional'},
    {'imagePath': 'assets/metal.jpeg', 'genreName': 'Metal'},
    {'imagePath': 'assets/indie.jpeg', 'genreName': 'Indie'},
    {'imagePath': 'assets/soul.jpeg', 'genreName': 'Soul'},
    {'imagePath': 'assets/punk.jpg', 'genreName': 'Punk'},
    {'imagePath': 'assets/fusion.jpeg', 'genreName': 'Fusion'},
  ];

  final List<String> genres = [
    'Indian classical',
    'Western classical',
    'Pop',
    'Rock',
    'Jazz',
    'Blues',
    'Hip-hop',
    'Electronic',
    'Folk',
    'Ghazal',
    'Devotional',
    'Metal',
    'Indie',
    'Soul',
    'Punk',
    'Fusion',
  ];

  Future<void> _fetchProfileData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID
      if (userId == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          _nameController.text = userData?['name'] ?? ''; // Fetch and set the name
          _usernameController.text = userData?['username'] ?? ''; // Fetch and set the username
          _bioController.text = userData?['bio'] ?? ''; // Fetch and set the bio
        });
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }
  Future<void> _fetchFavoriteGenres() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('User not logged in');
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData.containsKey('favoriteGenres')) {
          setState(() {
            _favoriteGenres = List<String>.from(userData['favoriteGenres'] ?? []);
          });
        } else {
          // Handle the case where 'favoriteGenres' is not in the document
          print('No favoriteGenres field found in user document');
          setState(() {
            _favoriteGenres = []; // Initialize with an empty list
          });
        }
      } else {
        // Handle the case where the document does not exist
        print('User document does not exist');
        setState(() {
          _favoriteGenres = []; // Initialize with an empty list
        });
      }
    } catch (e) {
      print('Error fetching favorite genres: $e');
    }
  }
  void _saveChanges() async {
    // Collect data from the controllers
    final name = _nameController.text;
    final username = _usernameController.text;
    final bio = _bioController.text;

    // Ensure the user has selected some skills and genres
    if (name.isEmpty || username.isEmpty || _favoriteSkills.isEmpty || _favoriteGenres.isEmpty) {
      // Show a message to the user if any required fields are missing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields and select at least one skill and genre.'),
        ),
      );
      return;
    }

    // Perform save operation
    try {
      // Assuming you have a Firestore collection named 'users' and you are saving to a document with the current user's ID
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'name': name,
          'username': username,
          'bio': bio,
          'favoriteSkills': _favoriteSkills,
          'favoriteGenres': _favoriteGenres,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
          ),
        );
      } else {
        // Handle the case where the user is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not logged in.'),
          ),
        );
      }
    } catch (e) {
      // Handle errors
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile. Please try again later.'),
        ),
      );
    }
  }


  Future<void> _saveFavoriteGenres() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'favoriteGenres': _favoriteGenres,
      });
    } catch (e) {
      print('Error saving favorite genres: $e');
    }
  }


  Future<void> _fetchFavoriteSkills() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID
      if (userId == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          _favoriteSkills = List<String>.from(userData?['selectedSkills'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching favorite skills: $e');
    }
  }

  Future<List<Map<String, String>>> _fetchSkillsData() async {
    try {
      // Use predefined map for skill images
      return skillImages.entries.map((entry) {
        return {
          'skillName': entry.key,
          'imagePath': entry.value,
        };
      }).toList();
    } catch (e) {
      print('Error fetching skills data: $e');
      return [];
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final file = File(filePath);

      setState(() {
        _profileImage = file;
      });

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profilepics/$userId');
        try {
          await storageRef.putFile(file);
          final downloadUrl = await storageRef.getDownloadURL();

          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'imageUrl': downloadUrl,
          });

          // Reload profile data to update the image
          await _fetchProfileData();
        } catch (e) {
          print('Error uploading image: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:

         Container(
           height: double.infinity,

          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1f0d1d),
                Color(0xFF140f13),
              ],
              stops: [0.1, 0.2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and heading
                Container(
                  padding: EdgeInsets.only(top: 50, left: 20, right: 24),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context); // Navigate back when pressed
                        },
                      ),
                      SizedBox(width: 16),
                      // Heading
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Profile Picture and Text Fields Row
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Profile Picture
                      GestureDetector(
                        onTap: _pickImage,
                        child: ProfileAvatar(),
                      ),
                      SizedBox(width: 24),
                      // Column with Name and Username fields
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name Field
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(252, 146, 221, 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _nameController,
                                style: GoogleFonts.nunito(color: Colors.black),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter your name',
                                  hintStyle: GoogleFonts.nunito(color: Colors.black54),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            // Username Field
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(252, 146, 221, 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _usernameController,
                                style: GoogleFonts.nunito(color: Colors.black),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter your username',
                                  hintStyle: GoogleFonts.nunito(color: Colors.black54),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Bio Heading and Field
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bio Heading
                      Text(
                        'Bio',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Bio Field
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(252, 146, 221, 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _bioController,
                          maxLines: 3, // Allows multiple lines
                          style: GoogleFonts.nunito(color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter your bio',
                            hintStyle: GoogleFonts.nunito(color: Colors.black54),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Your Skills Section
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Skills',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 120, // Adjusted height for horizontal scroll
                        child: FutureBuilder<List<Map<String, String>>>(
                          future: _fetchSkillsData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error loading skills'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(child: Text('No skills available'));
                            } else {
                              final skills = snapshot.data!;

                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: skills.length,
                                itemBuilder: (context, index) {
                                  final skill = skills[index];
                                  final isSelected = _favoriteSkills.contains(skill['skillName']);

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _favoriteSkills.remove(skill['skillName']);
                                        } else {
                                          _favoriteSkills.add(skill['skillName']!);
                                        }
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? Color.fromARGB(255, 184, 55, 134) // Border color
                                              : Colors.transparent,
                                          width: 4,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: AssetImage(skill['imagePath']!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      width: 250, // Adjust the width of each tile
                                      child: Center(
                                        child: Text(
                                          skill['skillName']!,
                                          style: GoogleFonts.nunito(
                                            color: Colors.white,
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Container(


                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Favorite Genres Heading
                      Text(
                        'Favorite Genres',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Grid of Genres
                    Container(
                      height: 200, // Adjust the height as needed
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Number of columns in the grid
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: genreData.length, // Use genreData length
                        itemBuilder: (context, index) {
                          final genreItem = genreData[index];
                          final genreName = genreItem['genreName'] ?? '';
                          final imagePath = genreItem['imagePath'] ?? '';
                          final isSelected = _favoriteGenres.contains(genreName);

                          print('Checking genre: $genreName, isSelected: $isSelected'); // Debug print

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _favoriteGenres.remove(genreName);
                                } else {
                                  _favoriteGenres.add(genreName);
                                }
                                print('Updated _favoriteGenres: $_favoriteGenres'); // Debug print
                              });
                              // Save the updated favorite genres to Firestore
                              _saveFavoriteGenres();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(imagePath),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Color.fromRGBO(184, 55, 134, 1) : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  genreName,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ])
                ),
                SizedBox(height: 24 ,),
                // Save Button
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(184, 55, 134, 1), // Button color
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),
              ],
            ),
          ),
        ),

    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    return FutureBuilder<String?>(
      future: _fetchProfileImage(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
          );
        } else {
          final imageUrl = snapshot.data;

          return CircleAvatar(
            radius: 50,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                : null,
          );
        }
      },
    );
  }

  Future<String?> _fetchProfileImage(String? userId) async {
    if (userId == null) return null;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userDoc.data();
      return userData?['imageUrl'] as String?;
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }
}
