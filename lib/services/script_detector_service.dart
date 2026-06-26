/// Service to detect the dominant writing script of a text using Unicode code point ranges.
class ScriptDetectorService {
  /// Supported scripts in ScriptBridge.
  static const String telugu = 'Telugu';
  static const String hindi = 'Hindi'; // Devanagari
  static const String tamil = 'Tamil';
  static const String kannada = 'Kannada';
  static const String malayalam = 'Malayalam';
  static const String gujarati = 'Gujarati';
  static const String bengali = 'Bengali';
  static const String punjabi = 'Punjabi'; // Gurmukhi
  static const String english = 'English'; // Latin
  static const String unknown = 'Unknown';

  /// Supported Indic script ranges.
  static const Map<String, List<int>> _indicRanges = {
    hindi: [0x0900, 0x097F],      // Devanagari
    bengali: [0x0980, 0x09FF],    // Bengali
    punjabi: [0x0A00, 0x0A7F],    // Gurmukhi
    gujarati: [0x0A80, 0x0AFF],   // Gujarati
    tamil: [0x0B80, 0x0BFF],      // Tamil
    telugu: [0x0C00, 0x0C7F],     // Telugu
    kannada: [0x0C80, 0x0CFF],    // Kannada
    malayalam: [0x0D00, 0x0D7F],  // Malayalam
  };

  /// Check if a script is supported.
  bool isSupportedScript(String scriptName) {
    final supported = [
      telugu,
      hindi,
      tamil,
      kannada,
      malayalam,
      gujarati,
      bengali,
      punjabi,
      english
    ];
    return supported.contains(scriptName);
  }

  /// Determines if a character code point is Latin (English).
  bool _isLatin(int codeUnit) {
    return (codeUnit >= 0x0041 && codeUnit <= 0x005A) || // A-Z
           (codeUnit >= 0x0061 && codeUnit <= 0x007A) || // a-z
           (codeUnit >= 0x00C0 && codeUnit <= 0x00FF) || // Latin-1 Supplement
           (codeUnit >= 0x0100 && codeUnit <= 0x017F);   // Latin Extended-A
  }

  /// Checks if a character code unit corresponds to a digit (ASCII or Indic).
  bool _isDigit(int codeUnit) {
    // ASCII digits 0-9
    if (codeUnit >= 0x30 && codeUnit <= 0x39) return true;
    
    // Indic digits (offset 0x66 to 0x6F in each Indic Unicode block)
    for (final range in _indicRanges.values) {
      final startDigit = range[0] + 0x66;
      final endDigit = range[0] + 0x6F;
      if (codeUnit >= startDigit && codeUnit <= endDigit) return true;
    }
    return false;
  }

  /// Checks if a character code unit is punctuation or control/whitespace.
  bool _isPunctuationOrWhitespace(int codeUnit) {
    if (codeUnit <= 0x20 || codeUnit == 0x7F) return true; // control, spaces
    if (codeUnit >= 0x21 && codeUnit <= 0x2F) return true; // ! " # $ % & ' ( ) * + , - . /
    if (codeUnit >= 0x3A && codeUnit <= 0x40) return true; // : ; < = > ? @
    if (codeUnit >= 0x5B && codeUnit <= 0x60) return true; // [ \ ] ^ _ `
    if (codeUnit >= 0x7B && codeUnit <= 0x7E) return true; // { | } ~
    return false;
  }

  /// Detects the dominant script in a given text string.
  /// Returns a map with 'script' (String) and 'confidence' (double, 0-100).
  Map<String, dynamic> detectScript(String text) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return {'script': unknown, 'confidence': 0.0};
    }

    final counts = <String, int>{
      telugu: 0,
      hindi: 0,
      tamil: 0,
      kannada: 0,
      malayalam: 0,
      gujarati: 0,
      bengali: 0,
      punjabi: 0,
      english: 0,
    };

    int totalValidChars = 0;

    for (int i = 0; i < cleanText.length; i++) {
      final charCode = cleanText.codeUnitAt(i);
      
      // Skip digits, whitespace, and punctuation to prevent skewing
      if (_isDigit(charCode) || _isPunctuationOrWhitespace(charCode)) {
        continue;
      }

      bool matched = false;
      
      // Check Indic ranges
      for (final entry in _indicRanges.entries) {
        final range = entry.value;
        if (charCode >= range[0] && charCode <= range[1]) {
          counts[entry.key] = (counts[entry.key] ?? 0) + 1;
          totalValidChars++;
          matched = true;
          break;
        }
      }

      // Check Latin
      if (!matched && _isLatin(charCode)) {
        counts[english] = (counts[english] ?? 0) + 1;
        totalValidChars++;
      }
    }

    if (totalValidChars == 0) {
      return {'script': unknown, 'confidence': 0.0};
    }

    // Find the dominant script (highest count)
    String dominantScript = unknown;
    int maxCount = 0;
    
    counts.forEach((script, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantScript = script;
      }
    });

    final confidence = (maxCount / totalValidChars) * 100.0;

    return {
      'script': dominantScript,
      'confidence': double.parse(confidence.toStringAsFixed(1)),
    };
  }

  /// Calculates the confidence of a specific script in the text.
  double calculateConfidence(String text, String scriptName) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return 0.0;

    int scriptCharCount = 0;
    int totalValidChars = 0;

    final range = _indicRanges[scriptName];

    for (int i = 0; i < cleanText.length; i++) {
      final charCode = cleanText.codeUnitAt(i);

      if (_isDigit(charCode) || _isPunctuationOrWhitespace(charCode)) {
        continue;
      }

      totalValidChars++;

      if (scriptName == english) {
        if (_isLatin(charCode)) {
          scriptCharCount++;
        }
      } else if (range != null) {
        if (charCode >= range[0] && charCode <= range[1]) {
          scriptCharCount++;
        }
      }
    }

    if (totalValidChars == 0) return 0.0;
    return double.parse(((scriptCharCount / totalValidChars) * 100.0).toStringAsFixed(1));
  }
}
