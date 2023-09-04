import 'package:flutter/material.dart';
import 'home.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'info.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int currentPage = 1;

  List<Widget> pages = [HomePage(), HistoryPage()];
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    loadImageUrls();
  }

  Future<void> loadImageUrls() async {
    final storageReference =
        FirebaseStorage.instance.ref().child('cropped_face/');
    final listResult = await storageReference.listAll();
    imageUrls = await Future.wait(
        listResult.items.map((item) => item.getDownloadURL()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('History Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final storageReference =
                  FirebaseStorage.instance.ref().child('cropped_face/');
              final listResult = await storageReference.listAll();
              for (var item in listResult.items) {
                await item.delete();
              }
              setState(() {
                imageUrls.clear();
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (BuildContext context, int index) {
          final fileName = imageUrls[index].split('/').last;
          final ts = int.parse(fileName.split('_').last.split('.').first);
          final seenAt = DateTime.fromMillisecondsSinceEpoch(ts);
          final formattedTime =
              '${seenAt.hour}:${seenAt.minute}:${seenAt.second}';
          return ListTile(
            title: Text(
              'Face ${(index + 1)}',
              style: TextStyle(fontSize: 18),
            ),
            subtitle: Text(
              'Time seen: $formattedTime',
              style: TextStyle(fontSize: 16),
            ),
            leading: Hero(
              tag: 'image$index',
              child: Image.network(imageUrls[index]),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoPage(
                    imageUrl: imageUrls[index],
                    heroTag: 'image$index',
                    faceIndex: index + 1,
                    timeSeen: formattedTime,
                  ),
                ),
              );
            },
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
              Navigator.pop(context);
            }
          });
        },
      ),
    );
  }
}
