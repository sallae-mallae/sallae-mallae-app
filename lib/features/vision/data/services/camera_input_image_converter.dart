import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class CameraInputImageConverter {
  const CameraInputImageConverter();

  InputImage? convert({
    required CameraImage image,
    required CameraDescription camera,
  }) {
    final format = _inputImageFormat(image.format.group);

    if (format == null || image.planes.isEmpty) {
      return null;
    }

    final bytes = _concatenatePlanes(image);
    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );

    if (rotation == null) {
      return null;
    }

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(CameraImage image) {
    final buffer = WriteBuffer();

    for (final plane in image.planes) {
      buffer.putUint8List(plane.bytes);
    }

    return buffer.done().buffer.asUint8List();
  }

  InputImageFormat? _inputImageFormat(ImageFormatGroup formatGroup) {
    return switch (formatGroup) {
      ImageFormatGroup.nv21 => InputImageFormat.nv21,
      ImageFormatGroup.yuv420 =>
        Platform.isIOS ? InputImageFormat.yuv420 : InputImageFormat.yuv_420_888,
      ImageFormatGroup.bgra8888 => InputImageFormat.bgra8888,
      _ => null,
    };
  }
}
