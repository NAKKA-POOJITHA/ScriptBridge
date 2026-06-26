import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/unicode_ranges.dart';
import '../providers/scan_provider.dart';

/// Bottom sheet settings control panel for configuring languages, scanning, TTS and viewing history.
class ControlPanelWidget extends StatelessWidget {
  const ControlPanelWidget({super.key});

  /// Opens the control panel modal.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ControlPanelWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScanProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121E1E), // Dark slate theme
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.tealAccent.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Title
                    Text(
                      'ScriptBridge Control Panel',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 20),

                    // Live Scan Toggle
                    _buildPanelSection(
                      title: 'Camera & OCR Scanning',
                      child: SwitchListTile(
                        value: provider.isScanning,
                        onChanged: (_) => provider.toggleScanning(),
                        title: const Text('Live Text Capture', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          provider.isScanning ? 'Actively translating street signs' : 'Scanning paused',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        secondary: Icon(
                          provider.isScanning ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                          color: Colors.tealAccent,
                        ),
                        activeColor: Colors.tealAccent,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Script Selectors
                    _buildPanelSection(
                      title: 'Language Configuration',
                      child: Column(
                        children: [
                          _buildDropdownRow(
                            label: 'Source Script (OCR)',
                            value: provider.sourceScript,
                            onChanged: (val) {
                              if (val != null) provider.setSourceScript(val);
                            },
                          ),
                          const Divider(color: Colors.white10),
                          _buildDropdownRow(
                            label: 'Target Script (Transliteration)',
                            value: provider.targetScript,
                            onChanged: (val) {
                              if (val != null) provider.setTargetScript(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Accessibility & Speech (TTS) Controls
                    _buildPanelSection(
                      title: 'Accessibility & Audio Reading',
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: provider.isTtsAutoEnabled,
                            onChanged: (val) => provider.setAutoTts(val),
                            title: const Text('Auto-Speak Translations', style: TextStyle(color: Colors.white)),
                            subtitle: const Text('Read aloud overlays automatically', style: TextStyle(color: Colors.white54)),
                            secondary: Icon(
                              provider.isTtsAutoEnabled ? Icons.headset_rounded : Icons.headset_off_rounded,
                              color: Colors.tealAccent,
                            ),
                            activeColor: Colors.tealAccent,
                          ),
                          const Divider(color: Colors.white10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Speech Speed', style: TextStyle(color: Colors.white)),
                                    Text('${(provider.speechRate * 100).toInt()}%', style: const TextStyle(color: Colors.tealAccent)),
                                  ],
                                ),
                                Slider(
                                  value: provider.speechRate,
                                  min: 0.1,
                                  max: 1.0,
                                  activeColor: Colors.tealAccent,
                                  inactiveColor: Colors.white12,
                                  onChanged: (val) => provider.setSpeechRate(val),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Speech Pitch', style: TextStyle(color: Colors.white)),
                                    Text('${provider.speechPitch.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.tealAccent)),
                                  ],
                                ),
                                Slider(
                                  value: provider.speechPitch,
                                  min: 0.5,
                                  max: 1.5,
                                  activeColor: Colors.tealAccent,
                                  inactiveColor: Colors.white12,
                                  onChanged: (val) => provider.setSpeechPitch(val),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Caching & History Records
                    _buildPanelSection(
                      title: 'History Logs (${provider.history.length}/1000)',
                      headerAction: TextButton.icon(
                        onPressed: provider.history.isEmpty ? null : () => provider.clearHistory(),
                        icon: const Icon(Icons.delete_sweep_rounded, size: 18, color: Colors.redAccent),
                        label: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
                      ),
                      child: provider.history.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No scans recorded yet',
                                  style: TextStyle(color: Colors.white30),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.history.length > 5 ? 5 : provider.history.length, // Show up to 5 items in sheet
                              itemBuilder: (context, index) {
                                final record = provider.history[index];
                                return ListTile(
                                  leading: const Icon(Icons.history_rounded, color: Colors.white38),
                                  title: Text(
                                    record.transliteratedText,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    '${record.originalText} (${record.sourceScript} ➔ ${record.targetScript})',
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.volume_up_rounded, color: Colors.tealAccent),
                                    onPressed: () => provider.speakText(record.transliteratedText),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper to build structured section containers.
  Widget _buildPanelSection({required String title, required Widget child, Widget? headerAction}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                if (headerAction != null) headerAction,
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  /// Helper to render script dropdown rows.
  Widget _buildDropdownRow({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            dropdownColor: const Color(0xFF121E1E),
            style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.w600),
            underline: Container(height: 1, color: Colors.tealAccent.withOpacity(0.5)),
            items: UnicodeRanges.supportedScripts.map((script) {
              return DropdownMenuItem<String>(
                value: script,
                child: Text(UnicodeRanges.scriptDisplayNames[script] ?? script),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
