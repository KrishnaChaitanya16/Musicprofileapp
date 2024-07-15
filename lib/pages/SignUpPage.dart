import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muiscprofileapp/pages/SIgnInPage.dart';
import 'package:muiscprofileapp/pages/SkillsPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isUsernameAvailable = true;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<bool> _checkUsernameAvailability(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return result.docs.isEmpty;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final isUsernameAvailable =
      await _checkUsernameAvailability(_usernameController.text.trim());

      if (!isUsernameAvailable) {
        setState(() {
          _isUsernameAvailable = false;
        });
        return;
      }

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': _usernameController.text.trim(),
          'name': _nameController.text.trim(),
          'mobile': _mobileController.text.trim(),
          'email': _emailController.text.trim(),
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SkillsPage()),
        );
      } catch (e) {
        print('Error signing up: $e');
        // Handle sign up errors
      }
    }
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
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Create Account',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      'Enter your Username',
                      _usernameController,
                          (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Username';
                        }
                        return null;
                      },
                    ),
                    if (!_isUsernameAvailable)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Username not available',
                          style: GoogleFonts.nunito(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    SizedBox(height: 30), // Increased spacing
                    _buildTextField(
                      'Enter your Name',
                      _nameController,
                          (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30), // Increased spacing
                    _buildTextField(
                      'Enter your Mobile Number',
                      _mobileController,
                          (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Mobile Number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30), // Increased spacing
                    _buildTextField(
                      'Enter your Email',
                      _emailController,
                          (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid Email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30), // Increased spacing
                    _buildPasswordTextField(
                      'Enter your Password',
                      _passwordController,
                          (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30), // Increased spacing
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: Color(0xFF1a012f),
                      ),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 30), // Increased spacing
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInPage()),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Have an Account ? ",
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "Sign In",
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint,
      TextEditingController controller,
      FormFieldValidator<String> validator,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
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
      ),
    );
  }

  Widget _buildPasswordTextField(
      String hint,
      TextEditingController controller,
      FormFieldValidator<String> validator,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: !_isPasswordVisible,
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
          suffixIcon: GestureDetector(
            onTap: _togglePasswordVisibility,
            child: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
