import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:faceattend/services/face_recognition_service.dart';

class CameraPreviewWidget extends StatefulWidget {
  final Function(Uint8List) onFaceCaptured;
  final bool isProcessing;

  const CameraPreviewWidget({
    Key? key,
    required this.onFaceCaptured,
    this.isProcessing = false,
  }) : super(key: key);

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  CameraController? _controller;
  bool _isInitialized = false;
  final FaceRecognitionService _faceService = FaceRecognitionService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcessFrame() async {
    if (!_isInitialized || widget.isProcessing || _controller == null) return;

    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();

      // Extract face features
      final embedding = await _faceService.extractFaceFeatures(bytes);

      if (embedding != null) {
        widget.onFaceCaptured(bytes);
      }
    } catch (e) {
      debugPrint('Error capturing frame: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        // Overlay for face detection guidance
        if (!widget.isProcessing)
          Positioned.fill(
            child: CustomPaint(
              painter: FaceGuidePainter(),
            ),
          ),
        // Processing indicator
        if (widget.isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Processing...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw oval guide for face positioning
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * 0.7;
    final height = size.height * 0.8;
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    canvas.drawOval(rect, paint);

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    const bracketLength = 20.0;
    const margin = 20.0;

    // Top-left
    canvas.drawLine(
      Offset(margin, margin),
      Offset(margin + bracketLength, margin),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(margin, margin),
      Offset(margin, margin + bracketLength),
      bracketPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin - bracketLength, margin),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin, margin + bracketLength),
      bracketPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin + bracketLength, size.height - margin),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin, size.height - margin - bracketLength),
      bracketPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin - bracketLength, size.height - margin),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin, size.height - margin - bracketLength),
      bracketPaint,
    );

    // Draw instructions
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Position your face within the oval',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, size.height - 60),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
