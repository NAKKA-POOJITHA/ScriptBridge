import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/control_panel_widget.dart';
import '../widgets/text_overlay_widget.dart';

/// The main application screen that lays out camera, text overlays, and floating control nodes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Initialize Scan Provider on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScanProvider>(context, listen: false).initialize();
    });

    // 2. Setup standard pulsing indicator for live status
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScanProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          const Positioned.fill(
            child: CameraPreviewWidget(),
          ),

          // 2. Real-time OCR overlay
          if (provider.isScanning && provider.errorMessage == null && !provider.isLoading)
            const Positioned.fill(
              child: TextOverlayWidget(),
            ),

          // 3. Top Floating Panel (Status pill & quick configs)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Live status pill
                GestureDetector(
                  onTap: () => provider.toggleScanning(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: provider.isScanning ? Colors.tealAccent : Colors.amber,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (provider.isScanning)
                          FadeTransition(
                            opacity: _pulseAnimation,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.tealAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          provider.isScanning ? 'LIVE SCAN' : 'SCAN PAUSED',
                          style: TextStyle(
                            color: provider.isScanning ? Colors.tealAccent : Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Language connection label (Source -> Target)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    '${provider.sourceScript} ➔ ${provider.targetScript}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Floating Action Controls (Bottom right setting button, camera switcher)
          if (provider.errorMessage == null && !provider.isLoading)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Camera Switch (Front/Rear)
                  FloatingActionButton(
                    heroTag: 'cam_switch_btn',
                    onPressed: () {
                      provider.cameraService.switchCamera(provider.processFrame);
                    },
                    backgroundColor: const Color(0xFF1E2F2F),
                    foregroundColor: Colors.tealAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.tealAccent, width: 0.5),
                    ),
                    child: const Icon(Icons.flip_camera_android_rounded),
                  ),

                  // Stop Speech (Only shown if TTS is active)
                  // In this state, we check if playing. We can add a mute button.
                  FloatingActionButton(
                    heroTag: 'tts_stop_btn',
                    onPressed: () => provider.stopSpeaking(),
                    backgroundColor: const Color(0xFF1E2F2F),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 0.5),
                    ),
                    child: const Icon(Icons.volume_off_rounded),
                  ),

                  // Settings Panel Trigger
                  FloatingActionButton(
                    heroTag: 'settings_btn',
                    onPressed: () => ControlPanelWidget.show(context),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.tune_rounded),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
