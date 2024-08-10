import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muiscprofileapp/pages/landingpage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _textAnimation;
  late Animation<double> _iconAnimation;
  late Animation<double> _swipeIconAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _iconAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _swipeIconAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animations
    _controller.forward().whenComplete(() {
      // Animation for SymJam and music icon is done
      setState(() {
        // Trigger any required state changes here
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Landingpage()),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1a012f), Color(0xFFb0048c)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.15, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Transform.scale(
                        scale: _iconAnimation.value,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'lib/icons/music.png', // Ensure this path is correct
                              width: 50,
                              height: 50,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'SymJam',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _controller.value,
                      child: Column(
                        children: [
                          Transform.scale(
                            scale: _swipeIconAnimation.value,
                            child: Image.asset(
                              'lib/icons/right.png', // Ensure this path is correct
                              width: 40,
                              height: 40,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Swipe Up to Start',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
    );
  }
}
