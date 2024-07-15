import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muiscprofileapp/pages/Genrepage.dart'; // Firebase Firestore

class SkillsPage extends StatefulWidget {
  const SkillsPage({Key? key}) : super(key: key);

  @override
  _SkillsPageState createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user;

  // List of asset image paths and corresponding skill names
  List<Map<String, String>> skillsData = [
    {'imagePath': 'assets/songwriting.jpeg', 'skillName': 'Songwriting'},
    {'imagePath': 'assets/vocals.jpg', 'skillName': 'Vocals'},
    {'imagePath': 'assets/flute.jpg', 'skillName': 'Flute'},
    {'imagePath': 'assets/drums.jpeg', 'skillName': 'Drums'},
    {'imagePath': 'assets/veena.jpeg', 'skillName': 'Veena'},
    {'imagePath': 'assets/tabala.jpeg', 'skillName': 'Tabla'},
    // Add more data as needed
  ];

  bool _hasSelectedSkills = false;
  List<String> _selectedSkills = []; // List to store selected skill names

  @override
  void initState() {
    super.initState();
    _getUser(); // Initialize user
  }

  void _getUser() async {
    _user = _auth.currentUser!;
  }

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
              SizedBox(height: 50,),
              Text(
                'Mark Your Skills',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: skillsData.length,
                  itemBuilder: (context, index) {
                    bool isRightAligned = index % 2 == 0; // Alternate alignment starting with right alignment for the first image

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: isRightAligned
                          ? RightAlignedSkillTile(
                        imagePath: skillsData[index]['imagePath']!,
                        skillName: skillsData[index]['skillName']!,
                        onSelected: _handleSkillSelected,
                      )
                          : LeftAlignedSkillTile(
                        imagePath: skillsData[index]['imagePath']!,
                        skillName: skillsData[index]['skillName']!,
                        onSelected: _handleSkillSelected,
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
        onPressed: () {
          // Implement action for the floating action button
          if (_hasSelectedSkills) {
            _saveSelectedSkills(); // Save selected skills to Firebase
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GenrePage()), // Replace GenrePage with your existing genre page class
            );
          } else {
            // Show snackbar if no skills are selected
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Select at least one skill.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        backgroundColor: Colors.black, // Black background color
        child: Icon(Icons.arrow_forward,color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Adjust the location as needed
    );
  }

  void _handleSkillSelected(bool isSelected, String skillName) {
    setState(() {
      _hasSelectedSkills = _selectedSkills.isNotEmpty;
      if (isSelected && !_selectedSkills.contains(skillName)) {
        _selectedSkills.add(skillName);
      } else {
        _selectedSkills.remove(skillName);
      }
    });
  }

  void _saveSelectedSkills() async {
    try {
      // Update Firestore with selected skills for the user
      await _firestore.collection('users').doc(_user.uid).set({
        'selectedSkills': _selectedSkills,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving selected skills: $e');
    }
  }
}

class LeftAlignedSkillTile extends StatefulWidget {
  final String imagePath;
  final String skillName;
  final Function(bool, String) onSelected;

  const LeftAlignedSkillTile({
    required this.imagePath,
    required this.skillName,
    required this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  _LeftAlignedSkillTileState createState() => _LeftAlignedSkillTileState();
}

class _LeftAlignedSkillTileState extends State<LeftAlignedSkillTile> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected; // Toggle selection
          widget.onSelected(_isSelected, widget.skillName);
        });
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: _isSelected ? Color(0xFFb83786) : Colors.transparent,
                width: 5.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 130, // Adjusted height
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF0f001c),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Color(0xFF0f001c),
                      height: 130, // Adjusted height
                      child: Center(
                        child: Text(
                          widget.skillName,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSelected)
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
  }
}

class RightAlignedSkillTile extends StatefulWidget {
  final String imagePath;
  final String skillName;
  final Function(bool, String) onSelected;

  const RightAlignedSkillTile({
    required this.imagePath,
    required this.skillName,
    required this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  _RightAlignedSkillTileState createState() => _RightAlignedSkillTileState();
}

class _RightAlignedSkillTileState extends State<RightAlignedSkillTile> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected; // Toggle selection
          widget.onSelected(_isSelected, widget.skillName);
        });
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: _isSelected ? Color(0xFFb83786) : Colors.transparent,
                width: 5.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Color(0xFF0f001c),
                      height: 130, // Adjusted height
                      child: Center(
                        child: Text(
                          widget.skillName,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 130, // Adjusted height
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF0f001c),
                                  Colors.transparent,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSelected)
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
  }
}
