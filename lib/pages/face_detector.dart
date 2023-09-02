import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../util/face_detector_painter.dart';
import 'camera.dart';

class FaceDetectorPage extends StatefulWidget {
  const FaceDetectorPage({required this.cameras, Key? key}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  State<FaceDetectorPage> createState() => _FaceDetectorPageState();

}

class _FaceDetectorPageState extends State<FaceDetectorPage> {
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
    String text = 'face found ${faces.length}\n\n';
    for (final face in faces) {
      text += 'face ${face.boundingBox}\n\n';
    }
    _text = text;
    //_customPaint = null;
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
