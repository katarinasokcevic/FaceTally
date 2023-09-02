import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'home.dart';

const int personCount =20;

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: personCount,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text('Item ${(index+1)}'),
            leading: const Icon(Icons.person),
          );
        },
    );
  }
}
