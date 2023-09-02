import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';

import '../util/face_detector_painter.dart';
import 'camera.dart';

class FaceDetectorPage extends StatefulWidget {
  const FaceDetectorPage({required this.cameras, Key? key}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  State<FaceDetectorPage> createState() => _FaceDetectorPageState();

}

class _FaceDetectorPageState extends State<FaceDetectorPage> {
  int _faceCount = 0;

  //create face detector object
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return CameraPage(
      cameras:widget.cameras,
      customPaint: _customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      faceCount: _faceCount,
    );
  }

  Future<void> processImage(final InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = "";
    });
    final faces = await _faceDetector.processImage(inputImage);

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    }
    _faceCount = faces.length;
    String text = 'face found ${faces.length}\n\n';

    final storage = FirebaseStorage.instance;

    for (final face in faces) {

      // Convert face bounding box into an image
     /* final imageBytes = await convertFaceToImage(inputImage, face);

      // Generate a unique filename for each face (you can customize this)
      final fileName = 'face_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload the image to Firebase Storage
      final storageRef = storage.ref().child('faces/$fileName');
      final uploadTask = storageRef.putData(imageBytes);

      // Get the download URL of the uploaded image
      final downloadUrl = await (await uploadTask).ref.getDownloadURL();

      // Append the download URL to your text or save it to a list
      text += 'Face ${face.boundingBox}: $downloadUrl\n\n';*/


      text += 'face ${face.boundingBox}\n\n';
    }
    _text = text;
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

 /* Future<Uint8List> convertFaceToImage(InputImage inputImage, Face face) async {
    final image = inputImage.inputImageData!.image;
    final faceRect = face.boundingBox;

    // Crop the face region from the original image
    final croppedImage = await image.crop(Rect.fromPoints(
      Offset(max(0, faceRect.left), max(0, faceRect.top)),
      Offset(min(image.width.toDouble(), faceRect.right), min(image.height.toDouble(), faceRect.bottom)),
    ));

    // Convert the cropped image to bytes
    final ByteData byteData = await croppedImage.toByteData(format: ImageByteFormat.png);
    return Uint8List.view(byteData.buffer);
  }
*/


}
