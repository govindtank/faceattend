import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FaceRecognitionService {
  static final FaceRecognitionService _instance = FaceRecognitionService._internal();
  factory FaceRecognitionService() => _instance;
  FaceRecognitionService._internal();

  Interpreter? _interpreter;
  bool _isInitialized = false;

  // Model configuration
  static const int _inputSize = 112; // MobileFaceNet input size
  static const double _threshold = 0.6; // Similarity threshold

  Future<void> initialize(String modelPath) async {
    if (_isInitialized) return;

    try {
      // Load the TFLite model from assets
      _interpreter = await Interpreter.fromAsset(modelPath);
      _isInitialized = true;
      debugPrint('Face recognition service initialized');
    } catch (e) {
      debugPrint('Error initializing face recognition: $e');
      rethrow;
    }
  }

  Future<List<double>?> extractFaceFeatures(Uint8List imageBytes) async {
    if (!_isInitialized || _interpreter == null) {
      debugPrint('Face recognition not initialized');
      return null;
    }

    try {
      // Preprocess image
      final img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        debugPrint('Failed to decode image');
        return null;
      }

      // Resize to model input size
      final img.Image resized = img.copyResize(
        image,
        width: _inputSize,
        height: _inputSize,
      );

      // Normalize and convert to input tensor [1, 112, 112, 3]
      final input = List.generate(
        _inputSize,
        (i) => List.generate(
          _inputSize,
          (j) => [
            resized.getPixel(j, i).r / 255.0,
            resized.getPixel(j, i).g / 255.0,
            resized.getPixel(j, i).b / 255.0,
          ],
        ),
      ).reshape([1, _inputSize, _inputSize, 3]);

      // Run inference — MobileFaceNet outputs 128-dim embedding
      final output = List.filled(1 * 128, 0.0).reshape([1, 128]);
      _interpreter!.run(input, output);

      // L2 normalize embedding
      final embedding = output[0];
      final norm = sqrt(embedding.map((e) => e * e).reduce((a, b) => a + b));
      final normalizedEmbedding = embedding.map((e) => e / norm).toList();

      return normalizedEmbedding;
    } catch (e) {
      debugPrint('Error extracting face features: $e');
      return null;
    }
  }

  double calculateSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) return 0.0;

    double dotProduct = 0.0;
    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
    }
    // L2-normalized embeddings: dot product = cosine similarity
    return dotProduct;
  }

  bool isMatch(List<double> embedding1, List<double> embedding2,
      {double threshold = 0.6}) {
    return calculateSimilarity(embedding1, embedding2) >= threshold;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
