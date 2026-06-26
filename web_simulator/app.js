// 1. Database of Preloaded Street Signboards
const MOCK_SIGNBOARDS = {
  telugu: {
    originalText: 'విజయవాడ',
    script: 'Telugu',
    rect: { x: 25, y: 35, width: 50, height: 16 }, // percentage-based positioning for responsive display
    bgColor: 'linear-gradient(135deg, #0d1b2a, #1b263b)',
    borderColor: '#00f5d4'
  },
  kannada: {
    originalText: 'ಬೆಂಗಳೂರು',
    script: 'Kannada',
    rect: { x: 22, y: 38, width: 56, height: 18 },
    bgColor: 'linear-gradient(135deg, #2b2d42, #8d99ae)',
    borderColor: '#00f5d4'
  },
  hindi: {
    originalText: 'विजयवाड़ा',
    script: 'Hindi',
    rect: { x: 25, y: 35, width: 50, height: 16 },
    bgColor: 'linear-gradient(135deg, #370617, #6a040f)',
    borderColor: '#00f5d4'
  },
  tamil: {
    originalText: 'சென்னை',
    script: 'Tamil',
    rect: { x: 28, y: 38, width: 44, height: 16 },
    bgColor: 'linear-gradient(135deg, #1b4332, #2d6a4f)',
    borderColor: '#00f5d4'
  },
  malayalam: {
    originalText: 'തിരുവനന്തപുരം',
    script: 'Malayalam',
    rect: { x: 18, y: 34, width: 64, height: 20 },
    bgColor: 'linear-gradient(135deg, #3d348b, #7678ed)',
    borderColor: '#00f5d4'
  },
  bengali: {
    originalText: 'কলকাতা',
    script: 'Bengali',
    rect: { x: 26, y: 36, width: 48, height: 16 },
    bgColor: 'linear-gradient(135deg, #ffb703, #fb8500)',
    borderColor: '#00f5d4'
  },
  gujarati: {
    originalText: 'અમદાવાદ',
    script: 'Gujarati',
    rect: { x: 25, y: 35, width: 50, height: 16 },
    bgColor: 'linear-gradient(135deg, #4a5759, #dedbd2)',
    borderColor: '#00f5d4'
  },
  punjabi: {
    originalText: 'ਅੰਮ੍ਰਿਤਸਰ',
    script: 'Punjabi',
    rect: { x: 24, y: 35, width: 52, height: 16 },
    bgColor: 'linear-gradient(135deg, #3a0ca3, #7209b7)',
    borderColor: '#00f5d4'
  }
};

// 2. Unicode Ranges Configurations
const SCRIPT_BASES = {
  'Hindi': 0x0900,
  'Bengali': 0x0980,
  'Punjabi': 0x0A00,
  'Gujarati': 0x0A80,
  'Tamil': 0x0B80,
  'Telugu': 0x0C00,
  'Kannada': 0x0C80,
  'Malayalam': 0x0D00
};

const SCRIPT_RANGES = {
  'Hindi': [0x0900, 0x097F],
  'Bengali': [0x0980, 0x09FF],
  'Punjabi': [0x0A00, 0x0A7F],
  'Gujarati': [0x0A80, 0x0AFF],
  'Tamil': [0x0B80, 0x0BFF],
  'Telugu': [0x0C00, 0x0C7F],
  'Kannada': [0x0C80, 0x0CFF],
  'Malayalam': [0x0D00, 0x0D7F]
};

// 3. Transliteration Characters Matrix
const offsetToLatin = {
  0x02: 'm', 0x03: 'h', 0x05: 'a', 0x06: 'aa', 0x07: 'i', 0x08: 'ii', 0x09: 'u', 0x0A: 'uu', 0x0B: 'ru',
  0x0E: 'e', 0x0F: 'ee', 0x10: 'ai', 0x12: 'o', 0x13: 'oo', 0x14: 'au',
  0x15: 'k', 0x16: 'kh', 0x17: 'g', 0x18: 'gh', 0x19: 'ng', 0x1A: 'ch', 0x1B: 'chh', 0x1C: 'j', 0x1D: 'jh', 0x1E: 'ny',
  0x1F: 't', 0x20: 'th', 0x21: 'd', 0x22: 'dh', 0x23: 'n', 0x24: 't', 0x25: 'th', 0x26: 'd', 0x27: 'dh', 0x28: 'n',
  0x2A: 'p', 0x2B: 'ph', 0x2C: 'b', 0x2D: 'bh', 0x2E: 'm', 0x2F: 'y', 0x30: 'r', 0x31: 'rr', 0x32: 'l', 0x33: 'l',
  0x34: 'zh', 0x35: 'v', 0x36: 'sh', 0x37: 'sh', 0x38: 's', 0x39: 'h',
  0x3E: 'aa', 0x3F: 'i', 0x40: 'ii', 0x41: 'u', 0x42: 'uu', 0x43: 'ru', 0x46: 'e', 0x47: 'ee', 0x48: 'ai', 0x4A: 'o', 0x4B: 'oo', 0x4C: 'au',
  0x66: '0', 0x67: '1', 0x68: '2', 0x69: '3', 0x6A: '4', 0x6B: '5', 0x6C: '6', 0x6D: '7', 0x6E: '8', 0x6F: '9'
};

const latinToOffset = {
  aa: 0x06, ee: 0x0F, ii: 0x08, oo: 0x13, uu: 0x0A, ai: 0x10, au: 0x14,
  a: 0x05, i: 0x07, u: 0x09, e: 0x0E, o: 0x12,
  kh: 0x16, gh: 0x18, chh: 0x1B, ch: 0x1A, jh: 0x1D, th: 0x25, dh: 0x27, ph: 0x2B, bh: 0x2D, sh: 0x36, zh: 0x34,
  k: 0x15, g: 0x17, j: 0x1C, t: 0x24, d: 0x26, n: 0x28, p: 0x2A, b: 0x2C, m: 0x2E, y: 0x2F, r: 0x30, v: 0x35, w: 0x35, s: 0x38, h: 0x39, l: 0x32
};

// 4. Script Detection Engine
function detectScript(text) {
  const counts = {};
  Object.keys(SCRIPT_RANGES).forEach(lang => counts[lang] = 0);
  counts['English'] = 0;
  
  let validCharCount = 0;
  
  for (let i = 0; i < text.length; i++) {
    const code = text.charCodeAt(i);
    
    // Ignore digits, spacing and symbols
    if (code <= 64 || (code >= 91 && code <= 96) || code >= 123 && code <= 191) continue;
    
    let matched = false;
    for (const [lang, range] of Object.entries(SCRIPT_RANGES)) {
      if (code >= range[0] && code <= range[1]) {
        counts[lang]++;
        validCharCount++;
        matched = true;
        break;
      }
    }
    
    if (!matched && ((code >= 65 && code <= 90) || (code >= 97 && code <= 122))) {
      counts['English']++;
      validCharCount++;
    }
  }
  
  if (validCharCount === 0) return { script: 'Unknown', confidence: 0 };
  
  let dominant = 'Unknown';
  let maxCount = 0;
  Object.entries(counts).forEach(([lang, count]) => {
    if (count > maxCount) {
      maxCount = count;
      dominant = lang;
    }
  });
  
  return {
    script: dominant,
    confidence: Math.round((maxCount / validCharCount) * 100)
  };
}

// 5. Transliteration Engine
function foldToTamil(offset) {
  if (offset >= 0x16 && offset <= 0x18) return 0x15;
  if (offset === 0x1B || offset === 0x1D) return 0x1A;
  if (offset >= 0x20 && offset <= 0x22) return 0x1F;
  if (offset >= 0x25 && offset <= 0x27) return 0x24;
  if (offset >= 0x2B && offset <= 0x2D) return 0x2A;
  return offset;
}

function foldToPunjabi(offset) {
  if (offset === 0x18) return 0x17;
  if (offset === 0x1D) return 0x1C;
  if (offset === 0x22) return 0x21;
  if (offset === 0x27) return 0x26;
  if (offset === 0x2D) return 0x2C;
  return offset;
}

function getMatraOffset(vowelOffset) {
  switch (vowelOffset) {
    case 0x05: return -1;
    case 0x06: return 0x3E;
    case 0x07: return 0x3F;
    case 0x08: return 0x40;
    case 0x09: return 0x41;
    case 0x0A: return 0x42;
    case 0x0B: return 0x43;
    case 0x0E: return 0x46;
    case 0x0F: return 0x47;
    case 0x10: return 0x48;
    case 0x12: return 0x4A;
    case 0x13: return 0x4B;
    case 0x14: return 0x4C;
    default: return -1;
  }
}

function transliterate(text, srcScript, dstScript) {
  if (!text || text.trim() === '') return '';
  if (srcScript === dstScript) return text;
  
  // A. Indic -> English
  if (dstScript === 'English') {
    const srcBase = SCRIPT_BASES[srcScript];
    if (!srcBase) return text;
    
    let result = '';
    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i);
      if (code >= srcBase && code <= srcBase + 0x7F) {
        const offset = code - srcBase;
        const isConsonant = offset >= 0x15 && offset <= 0x39;
        
        if (isConsonant) {
          result += (offsetToLatin[offset] || '');
          let modified = false;
          if (i + 1 < text.length) {
            const nextCode = text.charCodeAt(i + 1);
            if (nextCode >= srcBase && nextCode <= srcBase + 0x7F) {
              const nextOffset = nextCode - srcBase;
              if (nextOffset >= 0x3E && nextOffset <= 0x4C) {
                result += (offsetToLatin[nextOffset] || '');
                i++;
                modified = true;
              } else if (nextOffset === 0x4D) {
                i++;
                modified = true;
              }
            }
          }
          if (!modified) result += 'a';
        } else {
          if (offset === 0x4D) continue;
          result += (offsetToLatin[offset] || String.fromCharCode(code));
        }
      } else {
        result += String.fromCharCode(code);
      }
    }
    return result;
  }
  
  // B. English -> Indic
  if (srcScript === 'English') {
    const dstBase = SCRIPT_BASES[dstScript];
    if (!dstBase) return text;
    
    let result = '';
    const lower = text.toLowerCase();
    const sortedKeys = Object.keys(latinToOffset).sort((a, b) => b.length - a.length);
    
    let i = 0;
    let prevWasConsonant = false;
    
    while (i < lower.length) {
      const code = lower.charCodeAt(i);
      if (code < 97 || code > 122) {
        result += String.fromCharCode(code);
        prevWasConsonant = false;
        i++;
        continue;
      }
      
      let matched = false;
      for (const key of sortedKeys) {
        if (lower.substring(i).startsWith(key)) {
          let offset = latinToOffset[key];
          const isVowel = offset >= 0x05 && offset <= 0x14;
          
          if (isVowel) {
            if (prevWasConsonant) {
              let matra = getMatraOffset(offset);
              if (matra !== -1) {
                if (dstScript === 'Hindi' || dstScript === 'Bengali' || dstScript === 'Gujarati' || dstScript === 'Punjabi') {
                  if (matra === 0x46) matra = 0x47;
                  if (matra === 0x4A) matra = 0x4B;
                }
                result += String.fromCharCode(dstBase + matra);
              }
            } else {
              let vowel = offset;
              if (dstScript === 'Hindi' || dstScript === 'Bengali' || dstScript === 'Gujarati' || dstScript === 'Punjabi') {
                if (vowel === 0x0E) vowel = 0x0F;
                if (vowel === 0x12) vowel = 0x13;
              }
              result += String.fromCharCode(dstBase + vowel);
            }
            prevWasConsonant = false;
          } else {
            if (prevWasConsonant) {
              result += String.fromCharCode(dstBase + 0x4D); // halant
            }
            let finalOffset = offset;
            if (dstScript === 'Tamil') finalOffset = foldToTamil(finalOffset);
            else if (dstScript === 'Punjabi') finalOffset = foldToPunjabi(finalOffset);
            
            result += String.fromCharCode(dstBase + finalOffset);
            prevWasConsonant = true;
          }
          i += key.length;
          matched = true;
          break;
        }
      }
      
      if (!matched) {
        result += String.fromCharCode(lower.charCodeAt(i));
        prevWasConsonant = false;
        i++;
      }
    }
    return result;
  }
  
  // C. Indic -> Indic
  const srcBase = SCRIPT_BASES[srcScript];
  const dstBase = SCRIPT_BASES[dstScript];
  if (!srcBase || !dstBase) return text;
  
  let result = '';
  for (let i = 0; i < text.length; i++) {
    const code = text.charCodeAt(i);
    if (code >= srcBase && code <= srcBase + 0x7F) {
      let offset = code - srcBase;
      if (dstScript === 'Tamil') offset = foldToTamil(offset);
      else if (dstScript === 'Punjabi') offset = foldToPunjabi(offset);
      
      const isNorthernTarget = dstScript === 'Hindi' || dstScript === 'Bengali' || dstScript === 'Gujarati' || dstScript === 'Punjabi';
      if (isNorthernTarget) {
        if (offset === 0x0E) offset = 0x0F;
        if (offset === 0x12) offset = 0x13;
        if (offset === 0x46) offset = 0x47;
        if (offset === 0x4A) offset = 0x4B;
      }
      
      result += String.fromCharCode(dstBase + offset);
    } else {
      result += String.fromCharCode(code);
    }
  }
  
  return result;
}

// 6. UI Logic & Event Handlers
document.addEventListener('DOMContentLoaded', () => {
  // Select DOM Nodes
  const selectMode = document.getElementById('select-mode');
  const selectSignboard = document.getElementById('select-signboard');
  const selectTarget = document.getElementById('select-target');
  const toggleScan = document.getElementById('toggle-scan');
  const toggleAutoTts = document.getElementById('toggle-auto-tts');
  const speechRate = document.getElementById('speech-rate');
  const speechPitch = document.getElementById('speech-pitch');
  const rateValLabel = document.getElementById('rate-val-label');
  const pitchValLabel = document.getElementById('pitch-val-label');
  const signboardBanner = document.getElementById('signboard-banner');
  const signboardGraphic = document.getElementById('signboard-graphic');
  const signboardDisplay = document.getElementById('signboard-display');
  const cameraVideo = document.getElementById('camera-video');
  const overlaysRoot = document.getElementById('overlays-root');
  const historyListRoot = document.getElementById('history-list-root');
  const btnClearHistory = document.getElementById('btn-clear-history');
  const scanStatusText = document.getElementById('scan-status-text');
  const signSelectItem = document.getElementById('sign-select-item');
  const selectSource = document.getElementById('select-source');
  const sourceSelectItem = document.getElementById('source-select-item');
  const captureActionItem = document.getElementById('capture-action-item');
  const btnCapture = document.getElementById('btn-capture');

  let activeStream = null;
  let ocrWorker = null;
  let ocrWorkerLangs = null;

  async function getOCRWorker(langs) {
    const key = JSON.stringify(langs);
    if (ocrWorker && ocrWorkerLangs === key) {
      return ocrWorker;
    }

    scanStatusText.innerText = 'INITIALIZING OCR ENGINE...';

    if (ocrWorker) {
      try {
        await ocrWorker.terminate();
      } catch (err) {
        console.error('Failed to terminate old worker:', err);
      }
      ocrWorker = null;
    }

    ocrWorker = await Tesseract.createWorker(langs);
    ocrWorkerLangs = key;
    return ocrWorker;
  }
  
  // A. Initialize UI Settings from LocalStorage
  speechRate.addEventListener('input', () => {
    rateValLabel.innerText = `${Math.round(speechRate.value * 100)}%`;
  });
  speechPitch.addEventListener('input', () => {
    pitchValLabel.innerText = `${speechPitch.value}x`;
  });

  // B. Local Database History
  function getCachedHistory() {
    return JSON.parse(localStorage.getItem('scriptbridge_history') || '[]');
  }

  function saveCacheRecord(orig, src, dst, trans) {
    let list = getCachedHistory();
    // Prevent duplicate
    list = list.filter(item => !(item.orig === orig && item.src === src && item.dst === dst));
    
    list.unshift({
      orig,
      src,
      dst,
      trans,
      time: new Date().toLocaleTimeString()
    });
    
    // Max 1000 items
    if (list.length > 1000) {
      list = list.slice(0, 1000);
    }
    
    localStorage.setItem('scriptbridge_history', JSON.stringify(list));
    renderHistory();
  }

  function renderHistory() {
    const list = getCachedHistory();
    historyListRoot.innerHTML = '';
    
    list.forEach(item => {
      const card = document.createElement('div');
      card.className = 'history-card';
      card.innerHTML = `
        <div class="history-info">
          <span class="history-translit">${item.trans}</span>
          <span class="history-orig">${item.orig} (${item.src} ➔ ${item.dst})</span>
        </div>
        <button class="history-play-btn material-icons">volume_up</button>
      `;
      
      // Bind Speak audio
      card.querySelector('.history-play-btn').addEventListener('click', () => {
        speakTranslit(item.trans, item.dst);
      });
      
      historyListRoot.appendChild(card);
    });
  }

  btnClearHistory.addEventListener('click', () => {
    localStorage.setItem('scriptbridge_history', '[]');
    renderHistory();
  });

  // C. Speech Synthesis (TTS)
  function speakTranslit(text, script) {
    if (!text || text.trim() === '') return;
    
    // Stop speaking first
    window.speechSynthesis.cancel();
    
    const utterance = new SpeechSynthesisUtterance(text);
    
    // Determine Speech Language locale
    let locale = 'en-US';
    switch (script) {
      case 'Hindi': locale = 'hi-IN'; break;
      case 'Telugu': locale = 'te-IN'; break;
      case 'Tamil': locale = 'ta-IN'; break;
      case 'Kannada': locale = 'kn-IN'; break;
      case 'Malayalam': locale = 'ml-IN'; break;
      case 'Bengali': locale = 'bn-IN'; break;
      case 'Gujarati': locale = 'gu-IN'; break;
      case 'Punjabi': locale = 'pa-IN'; break;
    }
    
    utterance.lang = locale;
    utterance.rate = parseFloat(speechRate.value);
    utterance.pitch = parseFloat(speechPitch.value);
    
    window.speechSynthesis.speak(utterance);
  }

  // D. Core Translation Frame Loop
  function processActiveSignboard() {
    // Clear old overlays
    overlaysRoot.innerHTML = '';

    if (!toggleScan.checked) {
      scanStatusText.innerText = 'SCAN PAUSED';
      return;
    }
    scanStatusText.innerText = 'LIVE SCANNING';

    const selectedSign = selectSignboard.value;
    const signInfo = MOCK_SIGNBOARDS[selectedSign];
    if (!signInfo) return;

    // 1. OCR (Mock input text)
    const ocrText = signInfo.originalText;
    
    // 2. Script Detection
    const detection = detectScript(ocrText);
    
    // 3. Target Transliteration
    const targetScript = selectTarget.value;
    const transliterated = transliterate(ocrText, signInfo.script, targetScript);
    
    // 4. Cache
    saveCacheRecord(ocrText, signInfo.script, targetScript, transliterated);

    // 5. Render Bounding Box Overlays
    const box = document.createElement('div');
    box.className = 'translit-overlay-box';
    box.style.left = `${signInfo.rect.x}%`;
    box.style.top = `${signInfo.rect.y}%`;
    box.style.width = `${signInfo.rect.width}%`;
    box.style.height = `${signInfo.rect.height}%`;
    
    box.innerHTML = `
      <span class="overlay-speaker-icon material-icons">volume_up</span>
      <div class="overlay-texts">
        <span class="overlay-translit">${transliterated}</span>
        <span class="overlay-original">(${ocrText} • Conf: ${detection.confidence}%)</span>
      </div>
    `;

    // Click on overlay card to trigger speech synthesis
    box.addEventListener('click', () => {
      speakTranslit(transliterated, targetScript);
    });

    overlaysRoot.appendChild(box);

    // Autospeak if checked
    if (toggleAutoTts.checked) {
      speakTranslit(transliterated, targetScript);
    }
  }

  // E. Handle View Mode changes (Webcam vs Preloaded Offline Mock)
  const TESSERACT_LANGS = {
    'Telugu': 'tel',
    'Kannada': 'kan',
    'Hindi': 'hin',
    'Tamil': 'tam',
    'Malayalam': 'mal',
    'Bengali': 'ben',
    'Gujarati': 'guj',
    'Punjabi': 'pan',
    'English': 'eng'
  };

  let ocrInterval = null;
  let ocrProcessing = false;

  async function runWebcamOCR(force = false) {
    if (ocrProcessing) return;
    ocrProcessing = true;

    try {
      const mode = selectMode.value;
      if (mode !== 'webcam' || (!toggleScan.checked && !force)) {
        ocrProcessing = false;
        return;
      }

      if (cameraVideo.readyState < 2) {
        ocrProcessing = false;
        return;
      }

      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      const maxDim = 600;
      let w = cameraVideo.videoWidth;
      let h = cameraVideo.videoHeight;
      if (w > maxDim || h > maxDim) {
        if (w > h) {
          h = Math.round((h * maxDim) / w);
          w = maxDim;
        } else {
          w = Math.round((w * maxDim) / h);
          h = maxDim;
        }
      }
      canvas.width = w;
      canvas.height = h;
      ctx.drawImage(cameraVideo, 0, 0, w, h);

      const sourceLangName = selectSource.value;
      const tesseractLang = TESSERACT_LANGS[sourceLangName] || 'eng';
      const langs = tesseractLang === 'eng' ? ['eng'] : [tesseractLang, 'eng'];

      const worker = await getOCRWorker(langs);

      scanStatusText.innerText = 'SCANNING FRAME...';

      const result = await worker.recognize(canvas);

      if (selectMode.value !== 'webcam' || (!toggleScan.checked && !force)) {
        ocrProcessing = false;
        return;
      }

      scanStatusText.innerText = 'LIVE SCANNING';
      overlaysRoot.innerHTML = '';

      const lines = result.data.lines;
      const c_w = overlaysRoot.clientWidth;
      const c_h = overlaysRoot.clientHeight;

      const scale = Math.max(c_w / w, c_h / h);
      const offset_x = (c_w - w * scale) / 2;
      const offset_y = (c_h - h * scale) / 2;

      let hasDetections = false;

      for (const line of lines) {
        const text = line.text.trim();
        if (text.length < 3) continue;

        const detection = detectScript(text);
        const targetScript = selectTarget.value;
        const transliterated = transliterate(text, detection.script !== 'Unknown' ? detection.script : sourceLangName, targetScript);

        if (!transliterated || transliterated.trim() === '') continue;

        hasDetections = true;
        saveCacheRecord(text, detection.script !== 'Unknown' ? detection.script : sourceLangName, targetScript, transliterated);

        const bbox = line.bbox;
        const left = bbox.x0 * scale + offset_x;
        const top = bbox.y0 * scale + offset_y;
        const width = (bbox.x1 - bbox.x0) * scale;
        const height = (bbox.y1 - bbox.y0) * scale;

        const box = document.createElement('div');
        box.className = 'translit-overlay-box';
        box.style.left = `${left}px`;
        box.style.top = `${top}px`;
        box.style.width = `${width}px`;
        box.style.height = `${height}px`;

        box.innerHTML = `
          <span class="overlay-speaker-icon material-icons">volume_up</span>
          <div class="overlay-texts">
            <span class="overlay-translit">${transliterated}</span>
            <span class="overlay-original">(${text} • Conf: ${detection.confidence}%)</span>
          </div>
        `;

        box.addEventListener('click', () => {
          speakTranslit(transliterated, targetScript);
        });

        overlaysRoot.appendChild(box);

        if (toggleAutoTts.checked) {
          speakTranslit(transliterated, targetScript);
        }
      }

      if (!hasDetections && toggleScan.checked) {
        scanStatusText.innerText = 'LIVE SCANNING (NO TEXT)';
      }

    } catch (err) {
      console.error('OCR Error:', err);
      if (toggleScan.checked || force) {
        scanStatusText.innerText = 'OCR ERROR';
      }
    } finally {
      ocrProcessing = false;
    }
  }

  function startWebcamOCR() {
    stopWebcamOCR();
    runWebcamOCR(false);
    ocrInterval = setInterval(() => runWebcamOCR(false), 1500);
  }

  function stopWebcamOCR() {
    if (ocrInterval) {
      clearInterval(ocrInterval);
      ocrInterval = null;
    }
    overlaysRoot.innerHTML = '';
  }

  async function updateCaptureMode() {
    const mode = selectMode.value;
    
    // Clear old overlays during any transition
    overlaysRoot.innerHTML = '';
    
    if (mode === 'webcam') {
      signSelectItem.style.display = 'none';
      sourceSelectItem.style.display = 'block';
      captureActionItem.style.display = 'block';
      signboardDisplay.style.display = 'none';
      cameraVideo.style.display = 'block';
      signboardBanner.innerText = 'Camera Preview';
      
      try {
        activeStream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: 'environment' }
        });
        cameraVideo.srcObject = activeStream;
        cameraVideo.muted = true;
        
        try {
          await cameraVideo.play();
        } catch (playErr) {
          console.warn("Video play was interrupted/blocked:", playErr);
        }
        
        startWebcamOCR();
      } catch (err) {
        alert('Webcam Access Denied or Unreachable: ' + err.message);
        selectMode.value = 'mock';
        updateCaptureMode();
      }
    } else {
      // Offline mock signboards
      signSelectItem.style.display = 'block';
      sourceSelectItem.style.display = 'none';
      captureActionItem.style.display = 'none';
      signboardDisplay.style.display = 'flex';
      cameraVideo.style.display = 'none';
      
      if (activeStream) {
        activeStream.getTracks().forEach(t => t.stop());
        activeStream = null;
      }
      stopWebcamOCR();
      
      // Clean up Tesseract worker when switching back to mock mode
      if (ocrWorker) {
        scanStatusText.innerText = 'CLEANING UP OCR ENGINE...';
        try {
          await ocrWorker.terminate();
        } catch (err) {
          console.error('Error terminating worker:', err);
        }
        ocrWorker = null;
        ocrWorkerLangs = null;
      }
      
      updateSignboardDisplay();
    }
  }

  function updateSignboardDisplay() {
    const sign = selectSignboard.value;
    const signInfo = MOCK_SIGNBOARDS[sign];
    if (!signInfo) return;
    
    signboardGraphic.innerText = signInfo.originalText;
    signboardGraphic.style.background = signInfo.bgColor;
    signboardGraphic.style.borderColor = '#ffffff';
    signboardBanner.innerText = `Signboard: ${signInfo.script}`;
    
    // Process transliteration pipeline
    processActiveSignboard();
  }

  // Bind change listeners to update layouts dynamically
  selectMode.addEventListener('change', updateCaptureMode);
  selectSignboard.addEventListener('change', updateSignboardDisplay);
  selectTarget.addEventListener('change', () => {
    if (selectMode.value === 'webcam') {
      if (toggleScan.checked) runWebcamOCR();
    } else {
      processActiveSignboard();
    }
  });
  selectSource.addEventListener('change', () => {
    if (selectMode.value === 'webcam' && toggleScan.checked) {
      runWebcamOCR();
    }
  });
  toggleScan.addEventListener('change', () => {
    if (selectMode.value === 'webcam') {
      if (toggleScan.checked) {
        startWebcamOCR();
      } else {
        stopWebcamOCR();
        scanStatusText.innerText = 'SCAN PAUSED';
      }
    } else {
      processActiveSignboard();
    }
  });

  // Manual Capture action trigger
  btnCapture.addEventListener('click', () => {
    runWebcamOCR(true);
  });

  // Initialize
  updateCaptureMode();
  renderHistory();
});
