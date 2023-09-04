import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final int faceIndex;
  final String timeSeen;

  const InfoPage({
    Key? key,
    required this.imageUrl,
    required this.heroTag,
    required this.faceIndex,
    required this.timeSeen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: heroTag,
              child: Image.network(imageUrl),
            ),
            Text(
              'Face $faceIndex',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Time seen: $timeSeen',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}