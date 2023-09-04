import 'package:camera/camera.dart';
import 'package:facetally/pages/history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'face_detector.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  List<Widget> pages =  [HomePage(), HistoryPage()];

  final user = FirebaseAuth.instance.currentUser!;

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("FaceTally"),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: () async {
              await availableCameras().then((cameras) =>
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => FaceDetectorPage(cameras: cameras),
                  )));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 100, vertical: 250),
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "Open the camera",
                  style: TextStyle(
                    fontSize: 18, // Text style
                    color: Colors.white, // Text color
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: currentPage,
        onTap: (index) {
          setState(() {
            currentPage = index;
            if (index == 1) {
              // Navigate to History Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            }
          });
        },
      ),
    );
  }
}