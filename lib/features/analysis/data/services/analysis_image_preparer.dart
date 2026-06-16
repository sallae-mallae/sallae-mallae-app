import 'package:camera/camera.dart';
import 'package:sallae_mallae_app/core/image/image_base64_encoder.dart';
import 'package:sallae_mallae_app/core/image/image_compressor.dart';

class AnalysisImagePreparer {
  const AnalysisImagePreparer({
    this.compressor = const ImageCompressor(),
    this.encoder = const ImageBase64Encoder(),
  });

  final ImageCompressor compressor;
  final ImageBase64Encoder encoder;

  Future<String> prepareBase64(XFile imageFile) async {
    final originalBytes = await imageFile.readAsBytes();
    final compressedBytes = await compressor.compress(originalBytes);

    return encoder.encode(compressedBytes);
  }
}
