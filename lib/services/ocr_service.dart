import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/detected_text_model.dart';

/// Offline service using Google ML Kit to process camera frames and recognize text.
class OcrService {
  /// Map of script name to Google ML Kit text recognition script enums.
  static const Map<String, TextRecognitionScript> _scriptMapping = {
    'English': TextRecognitionScript.latin,
    'Hindi': TextRecognitionScript.devanagari,
    'Bengali': TextRecognitionScript.bengali,
    'Punjabi': TextRecognitionScript.gurmukhi,
    'Gujarati': TextRecognitionScript.gujarati,
    'Tamil': TextRecognitionScript.tamil,
    'Telugu': TextRecognitionScript.telugu,
    'Kannada': TextRecognitionScript.kannada,
    'Malayalam': TextRecognitionScript.malayalam,
  };

  /// The active text recognizer instance.
  TextRecognizer? _textRecognizer;
  String _activeScriptName = 'English';
  bool _isProcessing = false;

  OcrService() {
    _initRecognizer('English');
  }

  /// Initialize the text recognizer for a specific script.
  void _initRecognizer(String scriptName) {
    if (_textRecognizer != null && _activeScriptName == scriptName) return;

    _textRecognizer?.close();
    final scriptEnum = _scriptMapping[scriptName] ?? TextRecognitionScript.latin;
    _textRecognizer = TextRecognizer(script: scriptEnum);
    _activeScriptName = scriptName;
  }

  /// Set/change the text recognition script dynamically.
  void setSourceScript(String scriptName) {
    _initRecognizer(scriptName);
  }

  /// Processes a [CameraImage] frame and returns a list of [DetectedTextModel] blocks.
  /// Skips processing if the engine is currently busy to maintain 30 FPS preview.
  Future<List<DetectedTextModel>> processImageFrame(
      CameraImage image, CameraDescription camera) async {
    if (_isProcessing || _textRecognizer == null) return [];
    _isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(image, camera);
      if (inputImage == null) {
        _isProcessing = false;
        return [];
      }

      final recognizedText = await _textRecognizer!.processImage(inputImage);
      final List<DetectedTextModel> detectedBlocks = [];

      for (final block in recognizedText.blocks) {
        if (block.text.trim().isEmpty) continue;

        detectedBlocks.add(
          DetectedTextModel(
            originalText: block.text,
            boundingBox: block.boundingBox,
            confidence: 1.0, // Default confidence, as ML Kit doesn't expose it per block in this SDK
            timestamp: DateTime.now(),
          ),
        );
      }

      _isProcessing = false;
      return detectedBlocks;
    } catch (e) {
      debugPrint('OCR Frame processing error: $e');
      _isProcessing = false;
      return [];
    }
  }

  /// Converts a [CameraImage] from stream to ML Kit [InputImage].
  InputImage? _inputImageFromCameraImage(CameraImage image, CameraDescription camera) {
    try {
      // Concatenate all planes into a single byte buffer
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final imageRotation = _getRotation(camera.sensorOrientation);
      final imageFormat = InputImageFormatValue.fromRawValue(image.format.raw);
      if (imageFormat == null) return null;

      final plane = image.planes.first;
      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: imageFormat,
        bytesPerRow: plane.bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      debugPrint('Error converting CameraImage to InputImage: $e');
      return null;
    }
  }

  /// Map camera sensor orientation to ML Kit rotation.
  InputImageRotation _getRotation(int orientation) {
    switch (orientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  /// Close recognizer on dispose.
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
