import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// A full-screen camera capture dialog for Flutter Web.
/// Uses the browser's getUserMedia API to access the webcam.
class WebCameraCapture extends StatefulWidget {
  const WebCameraCapture({Key? key}) : super(key: key);

  /// Shows the camera dialog and returns captured image bytes, or null if cancelled.
  static Future<Uint8List?> capture(BuildContext context) async {
    return showDialog<Uint8List?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WebCameraCapture(),
    );
  }

  @override
  State<WebCameraCapture> createState() => _WebCameraCaptureState();
}

class _WebCameraCaptureState extends State<WebCameraCapture> {
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  String? _error;
  bool _isReady = false;
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'webcam-view-${DateTime.now().millisecondsSinceEpoch}';
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..setAttribute('playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.transform = 'scaleX(-1)'; // Mirror for selfie feel

      // Register the platform view
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) => _videoElement!,
      );

      // Request camera access
      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': {'facingMode': 'environment'}, // Prefer back camera
        'audio': false,
      });

      _videoElement!.srcObject = _mediaStream;
      await _videoElement!.play();

      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Camera access denied or not available.\n'
              'Please allow camera permissions in your browser.';
        });
      }
    }
  }

  Future<Uint8List?> _capturePhoto() async {
    if (_videoElement == null) return null;

    final canvas = html.CanvasElement(
      width: _videoElement!.videoWidth,
      height: _videoElement!.videoHeight,
    );

    // Draw without mirror so the captured image is correct
    final ctx = canvas.context2D;
    ctx.drawImage(_videoElement!, 0, 0);

    // Convert to JPEG blob
    final blob = await canvas.toBlob('image/jpeg', 0.85);
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    reader.onLoadEnd.listen((_) {
      final result = reader.result as Uint8List;
      completer.complete(result);
    });
    reader.readAsArrayBuffer(blob);

    return completer.future;
  }

  void _stopCamera() {
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _videoElement?.pause();
    _videoElement?.srcObject = null;
  }

  @override
  void dispose() {
    _stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Take Photo'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _stopCamera();
              Navigator.of(context).pop(null);
            },
          ),
        ),
        body: _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off,
                          size: 64, color: Colors.white54),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  // Camera preview
                  Expanded(
                    child: _isReady
                        ? HtmlElementView(viewType: _viewId)
                        : const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white)),
                  ),

                  // Capture button
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          final bytes = await _capturePhoto();
                          _stopCamera();
                          if (mounted) {
                            Navigator.of(context).pop(bytes);
                          }
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
