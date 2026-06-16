import 'dart:typed_data';

class ImageCompressionPolicy {
  const ImageCompressionPolicy({this.maxBytes = 1200 * 1024});

  final int maxBytes;
}

class ImageCompressor {
  const ImageCompressor({this.policy = const ImageCompressionPolicy()});

  final ImageCompressionPolicy policy;

  Future<Uint8List> compress(Uint8List bytes) async {
    return bytes;
  }
}
