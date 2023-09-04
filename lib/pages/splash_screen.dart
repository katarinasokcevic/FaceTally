import 'dart:async';
import 'package:flutter/material.dart';
import 'auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 3), // Start from bottom
      end: const Offset(0, 0),   // End at original position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceIn,
    ));

    _animationController.forward();

    Timer(
      const Duration(seconds: 4),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  AuthPage()),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: const Text(
                "FaceTally",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SlideTransition(
              position: _slideAnimation,
              child: const Icon(
                Icons.face_2,
                size: 100,
                color: Colors.pink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
