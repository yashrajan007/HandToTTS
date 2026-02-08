import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Stub for non-web platforms. WebCameraCapture is only functional on web.
class WebCameraCapture extends StatelessWidget {
  const WebCameraCapture({Key? key}) : super(key: key);

  /// Returns null on non-web platforms.
  static Future<Uint8List?> capture(BuildContext context) async {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
