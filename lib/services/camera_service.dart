import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service managing the device camera and active frame-by-frame image streaming.
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitializing = false;
  int _selectedCameraIndex = 0;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller != null && _controller!.value.isInitialized;
  bool get isInitializing => _isInitializing;
  List<CameraDescription> get cameras => _cameras;

  /// Requests camera permission. If granted, initializes the camera.
  Future<bool> requestPermissionAndInit() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      return await initialize();
    }
    return false;
  }

  /// Checks and starts camera initialization, setting up the rear camera by default.
  Future<bool> initialize() async {
    if (_isInitializing) return false;
    _isInitializing = true;

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _isInitializing = false;
        return false;
      }

      // Find the index of the rear camera
      int rearIndex = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      _selectedCameraIndex = rearIndex != -1 ? rearIndex : 0;

      await _initController();
      _isInitializing = false;
      return true;
    } catch (e) {
      debugPrint('CameraService init error: $e');
      _isInitializing = false;
      return false;
    }
  }

  /// Initializes the controller with OCR-optimized parameters.
  Future<void> _initController() async {
    if (_cameras.isEmpty) return;

    final description = _cameras[_selectedCameraIndex];

    // High resolution preset is used to detect smaller sign text.
    // Audio is disabled to improve startup times and reduce resource utilization.
    // YUV420 format is required for ML Kit text recognition on Android.
    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();
  }

  /// Starts the camera frame stream for OCR frame analysis.
  Future<void> startImageStream(void Function(CameraImage image) onFrame) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isStreamingImages) return;

    try {
      await _controller!.startImageStream(onFrame);
    } catch (e) {
      debugPrint('Error starting camera stream: $e');
    }
  }

  /// Stops streaming frames.
  Future<void> stopImageStream() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (!_controller!.value.isStreamingImages) return;

    try {
      await _controller!.stopImageStream();
    } catch (e) {
      debugPrint('Error stopping camera stream: $e');
    }
  }

  /// Switches between available cameras (e.g. front and rear).
  Future<void> switchCamera(void Function(CameraImage image) onFrame) async {
    if (_cameras.length < 2) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    
    // Stop current stream and dispose the old controller
    await stopImageStream();
    await dispose();

    // Setup the new controller
    await _initController();
    
    // Resume streaming
    await startImageStream(onFrame);
  }

  /// Synchronizes camera resources with application lifecycle states.
  Future<void> handleLifecycleState(AppLifecycleState state, {void Function(CameraImage image)? onFrame}) async {
    if (_controller == null) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Dispose camera during background state to free hardware resource
      await stopImageStream();
      await dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Re-initialize when application returns to the foreground
      await _initController();
      if (onFrame != null) {
        await startImageStream(onFrame);
      }
    }
  }

  /// Safely shuts down the camera and releases system resources.
  Future<void> dispose() async {
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) {
        try {
          await _controller!.stopImageStream();
        } catch (_) {}
      }
      await _controller!.dispose();
      _controller = null;
    }
  }
}
