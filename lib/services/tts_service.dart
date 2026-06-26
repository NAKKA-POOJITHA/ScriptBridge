import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Offline service using Flutter TTS to read transliterated texts aloud in target accents.
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  String _lastText = '';
  String _lastScript = 'English';

  bool get isPlaying => _isPlaying;

  TtsService() {
    _initTts();
  }

  /// Initializes callbacks to trace execution state
  void _initTts() {
    _flutterTts.setStartHandler(() {
      _isPlaying = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint('TTS Error: $msg');
      _isPlaying = false;
    });

    _flutterTts.setCancelHandler(() {
      _isPlaying = false;
    });

    _flutterTts.setPauseHandler(() {
      _isPlaying = false;
    });

    _flutterTts.setContinueHandler(() {
      _isPlaying = true;
    });
  }

  /// Sets the speech rate (typically 0.0 to 1.0, 0.5 is default)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  /// Sets the pitch (0.5 to 2.0, 1.0 is default)
  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  /// Maps the Script name to standard locale tag and verifies device support.
  Future<bool> setLanguageForScript(String scriptName) async {
    String langCode;
    switch (scriptName) {
      case 'Hindi':
        langCode = 'hi-IN';
        break;
      case 'Telugu':
        langCode = 'te-IN';
        break;
      case 'Tamil':
        langCode = 'ta-IN';
        break;
      case 'Kannada':
        langCode = 'kn-IN';
        break;
      case 'Malayalam':
        langCode = 'ml-IN';
        break;
      case 'Bengali':
        langCode = 'bn-IN';
        break;
      case 'Gujarati':
        langCode = 'gu-IN';
        break;
      case 'Punjabi':
        langCode = 'pa-IN';
        break;
      case 'English':
      default:
        langCode = 'en-US';
        break;
    }

    try {
      final isAvailable = await _flutterTts.isLanguageAvailable(langCode);
      if (isAvailable) {
        await _flutterTts.setLanguage(langCode);
        return true;
      }
    } catch (e) {
      debugPrint('TTS Check error for $langCode: $e');
    }
    
    // Fallback to English US
    await _flutterTts.setLanguage('en-US');
    return false;
  }

  /// Synthesizes speech from the given string in target script's accent.
  Future<void> speak(String text, String scriptName) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    _lastText = cleanText;
    _lastScript = scriptName;

    await stop();
    await setLanguageForScript(scriptName);

    try {
      await _flutterTts.speak(cleanText);
    } catch (e) {
      debugPrint('TTS Speak exception: $e');
      _isPlaying = false;
    }
  }

  /// Stops the current speech.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('TTS Stop error: $e');
    }
  }

  /// Pauses the current speech.
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('TTS Pause error: $e');
    }
  }

  /// Resumes speech (or restarts if native pause is unavailable).
  Future<void> resume() async {
    if (_lastText.isEmpty) return;
    try {
      // Some versions/OS do not fully support pause/resume natively.
      // Re-triggering speak for the stored text serves as a reliable fallback.
      await speak(_lastText, _lastScript);
    } catch (e) {
      debugPrint('TTS Resume error: $e');
    }
  }

  /// Releases resources.
  void dispose() {
    stop();
  }
}
