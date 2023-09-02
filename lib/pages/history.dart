import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'home.dart';

const int personCount=10;

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int currentPage = 1;

  List<Widget> pages =  [HomePage(), HistoryPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('History Page'),
      ),
      body: ListView.builder(
        itemCount: personCount,
        itemBuilder: (BuildContext context, int index) {
          final currentTime = DateTime.now();
          final formattedTime = '${currentTime.hour}:${currentTime.minute}:${currentTime.second}';
          return ListTile(
            title: Text('Face ${(index + 1)}'),
            subtitle: Text('Time: $formattedTime'),
            leading: const Icon(Icons.person),
          );
        },
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
            if (index == 0) {
              // Navigate to Camera Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          });
        },
      ),
    );
  }
}