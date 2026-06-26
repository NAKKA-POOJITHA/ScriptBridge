import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/detected_text_model.dart';
import '../providers/scan_provider.dart';

/// Overlay widget that translates and scales OCR bounding boxes, rendering
/// transliterated labels in real time directly on top of the physical signs.
class TextOverlayWidget extends StatelessWidget {
  const TextOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScanProvider>(context);
    final detectedItems = provider.detectedItems;
    final controller = provider.cameraService.controller;

    if (controller == null || !controller.value.isInitialized || detectedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Camera preview size (usually landscape, e.g. 1280x720)
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return const SizedBox.shrink();
    
    final imageSize = Size(previewSize.width, previewSize.height);
    final sensorOrientation = controller.description.sensorOrientation;

    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: detectedItems.map((item) {
            final rect = _scaleRect(
              rect: item.boundingBox,
              imageSize: imageSize,
              widgetSize: widgetSize,
              sensorOrientation: sensorOrientation,
            );

            // Slightly inflate the rect padding for aesthetic spacing
            final paddedRect = Rect.fromLTRB(
              (rect.left - 4).clamp(0, widgetSize.width),
              (rect.top - 4).clamp(0, widgetSize.height),
              (rect.right + 4).clamp(0, widgetSize.width),
              (rect.bottom + 4).clamp(0, widgetSize.height),
            );

            return Positioned(
              left: paddedRect.left,
              top: paddedRect.top,
              width: paddedRect.width,
              height: paddedRect.height,
              child: _OverlayLabel(
                item: item,
                onTap: () {
                  // Speak transliterated text on click
                  provider.speakText(item.transliteratedText);
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Transforms camera frame bounding box coordinates into screen coordinates.
  Rect _scaleRect({
    required Rect rect,
    required Size imageSize,
    required Size widgetSize,
    required int sensorOrientation,
  }) {
    double left, top, width, height;

    // Flutter Camera frame sizes are orientation-dependent.
    // Portrait captures (90/270 degrees) swap width/height coordinates.
    if (sensorOrientation == 90 || sensorOrientation == 270) {
      final double scaleX = widgetSize.width / imageSize.height;
      final double scaleY = widgetSize.height / imageSize.width;

      if (sensorOrientation == 90) {
        // 90 degrees clockwise rotation
        left = widgetSize.width - (rect.bottom * scaleX);
        top = rect.left * scaleY;
      } else {
        // 270 degrees clockwise rotation
        left = rect.top * scaleX;
        top = widgetSize.height - (rect.right * scaleY);
      }
      width = rect.height * scaleX;
      height = rect.width * scaleY;
    } else {
      // 0 or 180 degrees (no swap)
      final double scaleX = widgetSize.width / imageSize.width;
      final double scaleY = widgetSize.height / imageSize.height;

      left = rect.left * scaleX;
      top = rect.top * scaleY;
      width = rect.width * scaleX;
      height = rect.height * scaleY;
    }

    return Rect.fromLTWH(left, top, width, height);
  }
}

/// A premium glassmorphic tag displaying transliterated text.
class _OverlayLabel extends StatefulWidget {
  final DetectedTextModel item;
  final VoidCallback onTap;

  const _OverlayLabel({
    required this.item,
    required this.onTap,
  });

  @override
  State<_OverlayLabel> createState() => _OverlayLabelState();
}

class _OverlayLabelState extends State<_OverlayLabel> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _animController.forward(),
        onTapUp: (_) {
          _animController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _animController.reverse(),
        child: Container(
          decoration: BoxDecoration(
            // Premium glassmorphic background
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.tealAccent.withOpacity(0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Voice Indicator Icon
              Icon(
                Icons.volume_up_rounded,
                color: Colors.tealAccent.shade200,
                size: 14,
              ),
              const SizedBox(width: 6),
              // Translated Text
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.item.transliteratedText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '(${widget.item.originalText})',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
