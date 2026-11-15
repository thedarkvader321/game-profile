import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  ImageUtils._();

  static Future<String?> pickImageAsBase64() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 72,
      );
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }

  static Uint8List? decodeBase64(String? src) {
    if (src == null || src.isEmpty) return null;
    try {
      return base64Decode(src);
    } catch (_) {
      return null;
    }
  }
}
