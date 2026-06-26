import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/detected_text_model.dart';
import '../models/scan_history_model.dart';
import '../services/cache_service.dart';
import '../services/camera_service.dart';
import '../services/ocr_service.dart';
import '../services/script_detector_service.dart';
import '../services/transliteration_service.dart';
import '../services/tts_service.dart';

/// State management provider coordinating the ScriptBridge processing pipeline.
class ScanProvider extends ChangeNotifier with WidgetsBindingObserver {
  // Services
  final CameraService _cameraService = CameraService();
  final OcrService _ocrService = OcrService();
  final ScriptDetectorService _scriptDetectorService = ScriptDetectorService();
  final TransliterationService _transliterationService = TransliterationService();
  final CacheService _cacheService = CacheService();
  final TtsService _ttsService = TtsService();

  // App state
  String _sourceScript = 'Telugu'; // Initial source script
  String _targetScript = 'English'; // Initial target transliteration language
  bool _isScanning = true;
  bool _isTtsAutoEnabled = false;
  double _speechRate = 0.5;
  double _speechPitch = 1.0;

  List<DetectedTextModel> _detectedItems = [];
  List<ScanHistoryModel> _history = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDisposed = false;

  // Getters
  CameraService get cameraService => _cameraService;
  String get sourceScript => _sourceScript;
  String get targetScript => _targetScript;
  bool get isScanning => _isScanning;
  bool get isTtsAutoEnabled => _isTtsAutoEnabled;
  double get speechRate => _speechRate;
  double get speechPitch => _speechPitch;
  List<DetectedTextModel> get detectedItems => _detectedItems;
  List<ScanHistoryModel> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ScanProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Initialize all required services and the camera.
  Future<void> initialize() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      // 1. Initialize Cache
      await _cacheService.init();
      _history = _cacheService.getHistory();

      // 2. Setup initial OCR source language
      _ocrService.setSourceScript(_sourceScript);

      // 3. Initialize Camera (requests permission automatically)
      final hasPermission = await _cameraService.requestPermissionAndInit();
      if (!hasPermission) {
        _setErrorMessage('Camera permission was denied or camera initialization failed.');
        _setLoading(false);
        return;
      }

      // 4. Start processing stream
      if (_isScanning) {
        await _cameraService.startImageStream(processFrame);
      }

      _setLoading(false);
    } catch (e) {
      _setErrorMessage('Initialization failed: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// Core frame processor callback running at ~30 fps
  Future<void> processFrame(CameraImage image) async {
    if (_isDisposed || !_isScanning || _isLoading || _cameraService.controller == null) {
      return;
    }

    // Process frame using OCR service
    final rawBlocks = await _ocrService.processImageFrame(
      image,
      _cameraService.controller!.description,
    );

    if (rawBlocks.isEmpty) {
      if (_detectedItems.isNotEmpty) {
        _detectedItems = [];
        notifyListeners();
      }
      return;
    }

    final List<DetectedTextModel> processedBlocks = [];

    for (final block in rawBlocks) {
      // 1. Detect Source Script using Unicode Ranges
      final scriptResult = _scriptDetectorService.detectScript(block.originalText);
      final String script = scriptResult['script'];
      final double confidence = scriptResult['confidence'];

      // 2. Perform Transliteration (Check cache first, else compute & save)
      String transliteratedText = '';
      final cachedResult = _cacheService.getResult(
        originalText: block.originalText,
        sourceScript: _sourceScript,
        targetScript: _targetScript,
      );

      if (cachedResult != null) {
        transliteratedText = cachedResult.transliteratedText;
      } else {
        transliteratedText = _transliterationService.transliterate(
          block.originalText,
          _sourceScript,
          _targetScript,
        );

        await _cacheService.saveResult(
          originalText: block.originalText,
          sourceScript: _sourceScript,
          targetScript: _targetScript,
          transliteratedText: transliteratedText,
        );
      }

      processedBlocks.add(
        block.copyWith(
          detectedScript: script,
          confidence: confidence,
          transliteratedText: transliteratedText,
        ),
      );
    }

    // Update detected overlays
    _detectedItems = processedBlocks;
    _history = _cacheService.getHistory(); // Keep history list fresh
    notifyListeners();

    // Auto-TTS execution (speak first detected block if enabled and changes)
    if (_isTtsAutoEnabled && processedBlocks.isNotEmpty) {
      final firstBlock = processedBlocks.first;
      if (firstBlock.transliteratedText.isNotEmpty) {
        await speakText(firstBlock.transliteratedText);
      }
    }
  }

  /// Changes the target script for translation.
  Future<void> setTargetScript(String scriptName) async {
    if (_targetScript == scriptName) return;
    _targetScript = scriptName;
    _detectedItems = []; // Clear current previews so new frames display updated language
    notifyListeners();
  }

  /// Changes the expected source script. Re-initializes OCR recognizer.
  Future<void> setSourceScript(String scriptName) async {
    if (_sourceScript == scriptName) return;
    _sourceScript = scriptName;
    _ocrService.setSourceScript(_sourceScript);
    _detectedItems = [];
    notifyListeners();
  }

  /// Toggle scanning state (pause/resume frame processing).
  Future<void> toggleScanning() async {
    _isScanning = !_isScanning;
    _detectedItems = [];

    if (_isScanning) {
      await _cameraService.startImageStream(processFrame);
    } else {
      await _cameraService.stopImageStream();
    }
    notifyListeners();
  }

  /// Sets auto text-to-speech option.
  void setAutoTts(bool enabled) {
    _isTtsAutoEnabled = enabled;
    if (!enabled) {
      _ttsService.stop();
    }
    notifyListeners();
  }

  /// Sets TTS speed.
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _ttsService.setSpeechRate(rate);
    notifyListeners();
  }

  /// Sets TTS pitch.
  Future<void> setSpeechPitch(double pitch) async {
    _speechPitch = pitch;
    await _ttsService.setPitch(pitch);
    notifyListeners();
  }

  /// Speaks transliterated text aloud using correct language accent.
  Future<void> speakText(String text) async {
    await _ttsService.speak(text, _targetScript);
  }

  /// Stops voice readout.
  Future<void> stopSpeaking() async {
    await _ttsService.stop();
  }

  /// Clears cache history.
  Future<void> clearHistory() async {
    await _cacheService.clearCache();
    _history = [];
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setErrorMessage(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  /// Handle native App Lifecycle events.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;
    
    // Delegate lifecycle changes to camera service to prevent system memory leaks.
    _cameraService.handleLifecycleState(
      state,
      onFrame: _isScanning ? processFrame : null,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    _ocrService.dispose();
    _ttsService.dispose();
    _cacheService.dispose();
    super.dispose();
  }
}
