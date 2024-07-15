import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muiscprofileapp/pages/Homepage.dart';

class GenrePage extends StatefulWidget {
  const GenrePage({Key? key}) : super(key: key);

  @override
  _GenrePageState createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  final List<String> selectedGenres = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a012f), Color(0xFFb0048c)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.15, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Text(
                'Select Your Genres',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  itemCount: genreData.length,
                  itemBuilder: (context, index) {
                    final genre = genreData[index];
                    final isSelected = selectedGenres.contains(genre['genreName']);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedGenres.remove(genre['genreName']);
                          } else {
                            selectedGenres.add(genre['genreName']!);
                          }
                        });
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: isSelected ? Color(0xFFb83786) : Colors.transparent,
                                width: 5.0,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    genre['imagePath']!,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF0f001c).withOpacity(0.8),
                                          Color(0xFF0f001c).withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      genre['genreName']!,
                                      style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Icon(
                                Icons.check_circle,
                                color: Color(0xFFb83786),
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (selectedGenres.length >= 3) {
            try {
              User? user = _auth.currentUser;
              if (user != null) {
                await _firestore.collection('users').doc(user.uid).update({
                  'favoriteGenres': selectedGenres,
                });
                // Navigate to home page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              } else {
                print('User not logged in.');
              }
            } catch (e) {
              print('Error updating genres: $e');
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select at least three genres.'),
              ),
            );
          }
        },
        backgroundColor: Color(0xFF0f001c),
        child: const Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }
}

