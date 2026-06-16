import 'dart:convert';
import 'dart:typed_data';

class ImageBase64Encoder {
  const ImageBase64Encoder();

  String encode(Uint8List bytes) {
    return base64Encode(bytes);
  }
}
