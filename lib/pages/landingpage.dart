import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:muiscprofileapp/pages/SignInPage.dart';
import 'package:muiscprofileapp/pages/SignUpPage.dart';

class Landingpage extends StatelessWidget {
  const Landingpage({Key? key}) : super(key: key);

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
        child: Center(
          child: Stack(
            children: [
              Positioned(
                top: 150,
                left: 90,
                child: Text(
                  'Discover - Connect - Jam',
                  style: GoogleFonts.nunito(color: Colors.white, fontSize: 25),
                ),
              ),
              Positioned(
                top: 230,
                right: 30,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: _buildSphere(
                    260.0,
                    [Color(0xFF1a012f), Color(0xFFb0048c)],
                    [0.1, 0.9],
                    Alignment(-0.8, -0.8),
                    'Sign Up',
                  ),
                ),
              ),
              Positioned(
                bottom: 250,
                left: 40,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  },
                  child: _buildSphere(
                    220.0,
                    [Color(0xFF1a012f), Color(0xFFb0048c)],
                    [0.1, 0.9],
                    Alignment(0.8, -0.8),
                    'Sign In',
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        User? user = await _signInWithGoogle();
                        if (user != null) {
                          // Successfully signed in
                          // Navigate to home or profile page
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: Color(0xFF1a012f),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/icons/google.png',
                            height: 30,
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Continue with Google',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSphere(double size, List<Color> gradientColors, List<double> stops, Alignment focal, String text) {
    Color outerColor = gradientColors[0];
    Color centerColor = gradientColors[1];

    return Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  centerColor.withOpacity(0.95),
                  outerColor.withOpacity(1.0),
                ],
                stops: stops,
                center: Alignment.center,
                radius: 0.8,
                focal: focal,
                focalRadius: 0.05,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: size * 0.1,
                  spreadRadius: 0,
                  offset: Offset(0, -size * 0.1),
                ),
              ],
            ),
          ),
          Positioned(
            child: Text(
              text,
              style: GoogleFonts.nunito(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }
}
