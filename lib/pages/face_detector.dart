import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart';

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
  List<int> savedFaces = [];
  final storageRef = FirebaseStorage.instance.ref();

  //create face detector object
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  final jpg = imglib.JpegEncoder();

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraPage(
      cameras: widget.cameras,
      customPaint: _customPaint,
      onImage: (inputImage, image) {
        processImage(inputImage, image);
      },
      faceCount: _faceCount,
    );
  }

  Future<void> processImage(
      final InputImage inputImage, final CameraImage image) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);

      _faceCount = faces.length;
      print("# of faces: ${faces.length}");

      // Get the image data from the InputImage object
      imglib.Image? originalImage = convertImageToJpg(image);
      /*imglib.Image.fromBytes(
        width: (image.planes[0].bytesPerRow / 4).round(),
        height: image.height,
        bytes: image.planes[0].bytes.buffer,
      );*/
      print("image is $originalImage");

      if (originalImage != null) {
        // Decode the image data to create an Image object
        for (final face in faces) {
          final boundingBox = face.boundingBox;
          if (face.trackingId == null) {
            continue;
          }
          if (savedFaces.contains(face.trackingId)) {
            print("face already tracked, ${face.trackingId}");
            continue;
          }
          savedFaces.add(face.trackingId!);

          // Crop the image using the bounding box
          if (inputImage.inputImageData!.imageRotation.rawValue > 0) {
            originalImage = imglib.copyRotate(originalImage!, angle: inputImage.inputImageData!.imageRotation.rawValue);
          }
          final croppedImage = imglib.copyCrop(
            originalImage!,
            x: boundingBox.topLeft.dx.toInt(),
            y: boundingBox.topLeft.dy.toInt(),
            width: boundingBox.width.toInt(),
            height: boundingBox.height.toInt(),
          );

          // Create a reference to a location in Firebase Storage
          final ts = DateTime.now().millisecondsSinceEpoch;
          final storageReference =
              FirebaseStorage.instance.ref().child('cropped_face_$ts.jpg');

          print("uploading face to $ts");

          // Upload the cropped image file to Firebase Storage
          await storageReference.putData(jpg.encode(croppedImage));
        }
      }
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  imglib.Image? convertImageToJpg(CameraImage image) {
    try {
      imglib.Image? img;
      if (image.format.group == ImageFormatGroup.yuv420) {
        img = _convertYUV420(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        img = _convertBGRA8888(image);
      }

      return img;
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return null;
  }

// CameraImage BGRA8888 -> PNG
// Color
  imglib.Image _convertBGRA8888(CameraImage image) {
    return imglib.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: ChannelOrder.bgra,
    );
  }

// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
// Black
  static imglib.Image _convertYUV420(CameraImage cameraImage) {
    final imageWidth = cameraImage.width;
    final imageHeight = cameraImage.height;

    final yBuffer = cameraImage.planes[0].bytes;
    final uBuffer = cameraImage.planes[1].bytes;
    final vBuffer = cameraImage.planes[2].bytes;

    final int yRowStride = cameraImage.planes[0].bytesPerRow;
    final int yPixelStride = cameraImage.planes[0].bytesPerPixel!;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = imglib.Image(width: imageWidth, height: imageHeight);

    for (int h = 0; h < imageHeight; h++) {
      int uvh = (h / 2).floor();

      for (int w = 0; w < imageWidth; w++) {
        int uvw = (w / 2).floor();

        final yIndex = (h * yRowStride) + (w * yPixelStride);

        // Y plane should have positive values belonging to [0...255]
        final int y = yBuffer[yIndex];

        // U/V Values are subsampled i.e. each pixel in U/V chanel in a
        // YUV_420 image act as chroma value for 4 neighbouring pixels
        final int uvIndex = (uvh * uvRowStride) + (uvw * uvPixelStride);

        // U/V values ideally fall under [-0.5, 0.5] range. To fit them into
        // [0, 255] range they are scaled up and centered to 128.
        // Operation below brings U/V values to [-128, 127].
        final int u = uBuffer[uvIndex];
        final int v = vBuffer[uvIndex];

        // Compute RGB values per formula above.
        int r = (y + v * 1436 / 1024 - 179).round();
        int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
        int b = (y + u * 1814 / 1024 - 227).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        image.setPixelRgb(w, h, r, g, b);
      }
    }

    return image;
  }
}
