import '../core/constants/unicode_ranges.dart';

/// Fully offline service to transliterate text between different Indic scripts and English (Latin).
class TransliterationService {
  /// Base Unicode offsets for each supported script block.
  static const Map<String, int> _scriptBases = {
    'Hindi': 0x0900,
    'Bengali': 0x0980,
    'Punjabi': 0x0A00,
    'Gujarati': 0x0A80,
    'Tamil': 0x0B80,
    'Telugu': 0x0C00,
    'Kannada': 0x0C80,
    'Malayalam': 0x0D00,
  };

  /// Phonetic mappings from Unicode offsets (relative to script base) to English (Latin) strings.
  static const Map<int, String> _offsetToLatin = {
    0x02: 'm',     // Anusvara
    0x03: 'h',     // Visarga
    0x05: 'a',     // Vowels
    0x06: 'aa',
    0x07: 'i',
    0x08: 'ii',
    0x09: 'u',
    0x0A: 'uu',
    0x0B: 'ru',
    0x0E: 'e',
    0x0F: 'ee',
    0x10: 'ai',
    0x12: 'o',
    0x13: 'oo',
    0x14: 'au',
    0x15: 'k',     // Consonants
    0x16: 'kh',
    0x17: 'g',
    0x18: 'gh',
    0x19: 'ng',
    0x1A: 'ch',
    0x1B: 'chh',
    0x1C: 'j',
    0x1D: 'jh',
    0x1E: 'ny',
    0x1F: 't',
    0x20: 'th',
    0x21: 'd',
    0x22: 'dh',
    0x23: 'n',
    0x24: 't',
    0x25: 'th',
    0x26: 'd',
    0x27: 'dh',
    0x28: 'n',
    0x2A: 'p',
    0x2B: 'ph',
    0x2C: 'b',
    0x2D: 'bh',
    0x2E: 'm',
    0x2F: 'y',
    0x30: 'r',
    0x31: 'rr',
    0x32: 'l',
    0x33: 'l',
    0x34: 'zh',
    0x35: 'v',
    0x36: 'sh',
    0x37: 'sh',
    0x38: 's',
    0x39: 'h',
    0x3E: 'aa',    // Matras
    0x3F: 'i',
    0x40: 'ii',
    0x41: 'u',
    0x42: 'uu',
    0x43: 'ru',
    0x46: 'e',
    0x47: 'ee',
    0x48: 'ai',
    0x4A: 'o',
    0x4B: 'oo',
    0x4C: 'au',
    0x66: '0',     // Digits
    0x67: '1',
    0x68: '2',
    0x69: '3',
    0x6A: '4',
    0x6B: '5',
    0x6C: '6',
    0x6D: '7',
    0x6E: '8',
    0x6F: '9',
  };

  /// Mappings from English letters/clusters to relative Unicode offsets.
  static const Map<String, int> _latinToOffset = {
    'aa': 0x06,
    'ee': 0x0F,
    'ii': 0x08,
    'oo': 0x13,
    'uu': 0x0A,
    'ai': 0x10,
    'au': 0x14,
    'a': 0x05,
    'i': 0x07,
    'u': 0x09,
    'e': 0x0E,
    'o': 0x12,
    'kh': 0x16,
    'gh': 0x18,
    'chh': 0x1B,
    'ch': 0x1A,
    'jh': 0x1D,
    'th': 0x25,
    'dh': 0x27,
    'ph': 0x2B,
    'bh': 0x2D,
    'sh': 0x36,
    'zh': 0x34,
    'k': 0x15,
    'g': 0x17,
    'j': 0x1C,
    't': 0x24,
    'd': 0x26,
    'n': 0x28,
    'p': 0x2A,
    'b': 0x2C,
    'm': 0x2E,
    'y': 0x2F,
    'r': 0x30,
    'v': 0x35,
    'w': 0x35,
    's': 0x38,
    'h': 0x39,
    'l': 0x32,
  };

  /// Transliterates text from a source script to a target script.
  String transliterate(String text, String sourceScript, String targetScript) {
    if (!validateInput(text)) return text;
    final normalized = normalizeText(text);

    if (sourceScript == targetScript) return normalized;

    // Indic -> English (Romanization)
    if (targetScript == 'English') {
      final base = _scriptBases[sourceScript];
      if (base == null) return normalized;
      return _indicToEnglish(normalized, base);
    }

    // English -> Indic (Phonetic Transliteration)
    if (sourceScript == 'English') {
      final targetBase = _scriptBases[targetScript];
      if (targetBase == null) return normalized;
      return _englishToIndic(normalized, targetScript, targetBase);
    }

    // Indic -> Indic (Unicode offset shifting)
    final srcBase = _scriptBases[sourceScript];
    final dstBase = _scriptBases[targetScript];
    if (srcBase == null || dstBase == null) return normalized;

    return _indicToIndic(normalized, sourceScript, targetScript, srcBase, dstBase);
  }

  /// Simple validations on text.
  bool validateInput(String text) {
    return text.trim().isNotEmpty;
  }

  /// Normalizes Indic unicode text patterns (e.g. cleans weird spacing).
  String normalizeText(String text) {
    // Trim and collapse double spaces
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Maps Indic consonant/vowel codes to nearest Tamil equivalents.
  int _foldToTamil(int offset) {
    // Tamil lacks aspirated consonants, map them to unaspirated forms
    if (offset >= 0x16 && offset <= 0x18) return 0x15; // kha, ga, gha -> ka (க)
    if (offset == 0x1B || offset == 0x1D) return 0x1A; // cha, jha -> ca (ச)
    if (offset >= 0x20 && offset <= 0x22) return 0x1F; // ttha, dda, ddha -> tta (ட)
    if (offset >= 0x25 && offset <= 0x27) return 0x24; // tha, da, dha -> ta (த)
    if (offset >= 0x2B && offset <= 0x2D) return 0x2A; // pha, ba, bha -> pa (ப)
    return offset;
  }

  /// Maps Indic consonant/vowel codes to Gurmukhi (Punjabi) equivalents.
  int _foldToPunjabi(int offset) {
    // Gurmukhi lacks voiced aspirate characters, fold to voiced equivalents
    if (offset == 0x18) return 0x17; // gha -> ga
    if (offset == 0x1D) return 0x1C; // jha -> ja
    if (offset == 0x22) return 0x21; // ddha -> dda
    if (offset == 0x27) return 0x26; // dha -> da
    if (offset == 0x2D) return 0x2C; // bha -> ba
    return offset;
  }

  /// Performs Unicode offset shifting between two Indic scripts.
  String _indicToIndic(String text, String srcName, String dstName, int srcBase, int dstBase) {
    final sb = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      
      // If code is within range of the source Indic script
      if (code >= srcBase && code <= srcBase + 0x7F) {
        int offset = code - srcBase;
        
        // Handle target-specific folds
        if (dstName == 'Tamil') {
          offset = _foldToTamil(offset);
        } else if (dstName == 'Punjabi') {
          offset = _foldToPunjabi(offset);
        }

        // Adjust vowels/matras if moving from/to South Indian scripts
        // Southern scripts use short e (0x0E) and short o (0x12).
        // Northern scripts (Devanagari, Bengali, Gujarati, Punjabi) use 0x0F for e, 0x13 for o.
        final isNorthernTarget = dstName == 'Hindi' || dstName == 'Bengali' || dstName == 'Gujarati' || dstName == 'Punjabi';
        if (isNorthernTarget) {
          if (offset == 0x0E) offset = 0x0F; // short e -> e
          if (offset == 0x12) offset = 0x13; // short o -> o
          if (offset == 0x46) offset = 0x47; // short e matra -> e matra
          if (offset == 0x4A) offset = 0x4B; // short o matra -> o matra
        }

        sb.writeCharCode(dstBase + offset);
      } else {
        sb.writeCharCode(code); // Keep other chars (English, numbers, spaces)
      }
    }
    return sb.toString();
  }

  /// Translates an Indic string to English phonetic representation.
  String _indicToEnglish(String text, int srcBase) {
    final sb = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if (code >= srcBase && code <= srcBase + 0x7F) {
        final offset = code - srcBase;
        final isConsonant = offset >= 0x15 && offset <= 0x39;

        if (isConsonant) {
          final cons = _offsetToLatin[offset] ?? '';
          sb.write(cons);

          // Look ahead to check if consonant is modified
          bool modified = false;
          if (i + 1 < text.length) {
            final nextCode = text.codeUnitAt(i + 1);
            if (nextCode >= srcBase && nextCode <= srcBase + 0x7F) {
              final nextOffset = nextCode - srcBase;
              if (nextOffset >= 0x3E && nextOffset <= 0x4C) {
                // Modified by vowel sign (matra)
                final matra = _offsetToLatin[nextOffset] ?? '';
                sb.write(matra);
                i++; // Skip processing the matra next loop
                modified = true;
              } else if (nextOffset == 0x4D) {
                // Halant (virama) - silences inherent vowel
                i++; // Skip halant
                modified = true;
              }
            }
          }
          if (!modified) {
            // Apply inherent vowel 'a'
            sb.write('a');
          }
        } else {
          // Vowels, digits, anusvara
          if (offset == 0x4D) continue; // Skip orphan virama
          sb.write(_offsetToLatin[offset] ?? String.fromCharCode(code));
        }
      } else {
        sb.writeCharCode(code);
      }
    }
    return sb.toString();
  }

  /// Dynamic stateful English-to-Indic transliterator using greedy parsing.
  String _englishToIndic(String text, String targetScript, int targetBase) {
    final sb = StringBuffer();
    final lowerText = text.toLowerCase();
    
    // Sort latin keys by length descending to match longest cluster first (greedy)
    final sortedKeys = _latinToOffset.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    int i = 0;
    bool prevWasConsonant = false;

    while (i < lowerText.length) {
      final charCode = lowerText.codeUnitAt(i);
      
      // Skip non-alphabetic chars
      if (charCode < 0x61 || charCode > 0x7A) {
        sb.writeCharCode(charCode);
        prevWasConsonant = false;
        i++;
        continue;
      }

      bool matched = false;
      for (final key in sortedKeys) {
        if (lowerText.startsWith(key, i)) {
          int offset = _latinToOffset[key]!;
          final isVowel = offset >= 0x05 && offset <= 0x14;
          
          if (isVowel) {
            if (prevWasConsonant) {
              // Convert vowel offset to vowel sign (matra) offset
              final matra = _getMatraOffset(offset);
              if (matra != -1) {
                int finalMatra = matra;
                if (targetScript == 'Hindi' || targetScript == 'Bengali' || targetScript == 'Gujarati' || targetScript == 'Punjabi') {
                  if (finalMatra == 0x46) finalMatra = 0x47;
                  if (finalMatra == 0x4A) finalMatra = 0x4B;
                }
                sb.writeCharCode(targetBase + finalMatra);
              }
            } else {
              // Independent Vowel
              int finalVowel = offset;
              if (targetScript == 'Hindi' || targetScript == 'Bengali' || targetScript == 'Gujarati' || targetScript == 'Punjabi') {
                if (finalVowel == 0x0E) finalVowel = 0x0F;
                if (finalVowel == 0x12) finalVowel = 0x13;
              }
              sb.writeCharCode(targetBase + finalVowel);
            }
            prevWasConsonant = false;
          } else {
            // Consonant
            if (prevWasConsonant) {
              // Add virama/halant between consecutive consonants (consonant conjunct)
              sb.writeCharCode(targetBase + 0x4D);
            }
            int finalOffset = offset;
            if (targetScript == 'Tamil') {
              finalOffset = _foldToTamil(finalOffset);
            } else if (targetScript == 'Punjabi') {
              finalOffset = _foldToPunjabi(finalOffset);
            }
            sb.writeCharCode(targetBase + finalOffset);
            prevWasConsonant = true;
          }
          i += key.length;
          matched = true;
          break;
        }
      }

      if (!matched) {
        sb.writeCharCode(lowerText.codeUnitAt(i));
        prevWasConsonant = false;
        i++;
      }
    }
    
    // If word ends with a consonant in English (like "raman"), we might want to append a halant.
    // For general street signs, let's keep it simple.
    return sb.toString();
  }

  /// Maps independent vowel offset to its dependent vowel sign (matra).
  int _getMatraOffset(int vowelOffset) {
    switch (vowelOffset) {
      case 0x05: return -1; // Inherent a, no matra
      case 0x06: return 0x3E; // aa matra
      case 0x07: return 0x3F; // i matra
      case 0x08: return 0x40; // ii matra
      case 0x09: return 0x41; // u matra
      case 0x0A: return 0x42; // uu matra
      case 0x0B: return 0x43; // vocalic r matra
      case 0x0E: return 0x46; // short e matra
      case 0x0F: return 0x47; // long e matra
      case 0x10: return 0x48; // ai matra
      case 0x12: return 0x4A; // short o matra
      case 0x13: return 0x4B; // long o matra
      case 0x14: return 0x4C; // au matra
      default: return -1;
    }
  }
}
