import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muiscprofileapp/pages/SkillsPage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sign In',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                _buildHeadingText('Email/Username'),
                SizedBox(height: 8),
                _buildTextField('Enter your Email/Username', _emailController),
                SizedBox(height: 20),
                _buildHeadingText('Password'),
                SizedBox(height: 8),
                _buildPasswordTextField('Enter your password', _passwordController),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _signInWithEmailAndPassword();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Color(0xFF1a012f),
                  ),
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider(color: Colors.white)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Or',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white)),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIconContainer('lib/icons/google.png'), // Replace with actual Google icon path
                    SizedBox(width: 20),
                    _buildSocialIconContainer('lib/icons/facebook.png'), // Replace with actual Facebook icon path
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeadingText(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.nunito(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white70,
        hintText: hint,
        hintStyle: GoogleFonts.nunito(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white60),
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white60),
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.nunito(color: Colors.black),
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white70,
        hintText: hint,
        hintStyle: GoogleFonts.nunito(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white60),
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white60),
          borderRadius: BorderRadius.circular(20.0),
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          child: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIconContainer(String iconPath) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Image.asset(
          iconPath,
          height: 30,
          width: 30,
        ),
      ),
    );
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to the next page after successful sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SkillsPage()),
      );
    } catch (e) {
      // Handle sign-in errors here
      print('Sign in error: $e');
      // Show a snackbar or dialog to the user indicating sign-in failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed. Please check your credentials and try again.'),
        ),
      );
    }
  }
}
