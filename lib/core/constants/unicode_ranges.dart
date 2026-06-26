/// Constants defining Unicode ranges and lists of supported scripts.
class UnicodeRanges {
  /// Script names supported by ScriptBridge.
  static const List<String> supportedScripts = [
    'Telugu',
    'Hindi', // Devanagari
    'Tamil',
    'Kannada',
    'Malayalam',
    'Gujarati',
    'Bengali',
    'Punjabi', // Gurmukhi
    'English', // Latin
  ];

  /// Script name mappings for UI display.
  static const Map<String, String> scriptDisplayNames = {
    'Telugu': 'తెలుగు (Telugu)',
    'Hindi': 'हिन्दी (Hindi)',
    'Tamil': 'தமிழ் (Tamil)',
    'Kannada': 'ಕನ್ನಡ (Kannada)',
    'Malayalam': 'മലയാളം (Malayalam)',
    'Gujarati': 'ગુજરાતી (Gujarati)',
    'Bengali': 'বাংলা (Bengali)',
    'Punjabi': 'ਪੰਜਾਬੀ (Punjabi)',
    'English': 'English (Latin)',
  };
}
