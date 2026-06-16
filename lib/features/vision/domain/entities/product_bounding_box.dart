class ProductBoundingBox {
  const ProductBoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.imageWidth,
    required this.imageHeight,
  });

  factory ProductBoundingBox.fromLTRB({
    required double left,
    required double top,
    required double right,
    required double bottom,
    required double imageWidth,
    required double imageHeight,
  }) {
    return ProductBoundingBox(
      left: left,
      top: top,
      width: right - left,
      height: bottom - top,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
  }

  final double left;
  final double top;
  final double width;
  final double height;
  final double imageWidth;
  final double imageHeight;

  double get right => left + width;

  double get bottom => top + height;

  double get centerX => left + width / 2;

  double get centerY => top + height / 2;

  double get area => width * height;

  double get normalizedLeft => imageWidth <= 0 ? 0 : left / imageWidth;

  double get normalizedTop => imageHeight <= 0 ? 0 : top / imageHeight;

  double get normalizedWidth => imageWidth <= 0 ? 0 : width / imageWidth;

  double get normalizedHeight => imageHeight <= 0 ? 0 : height / imageHeight;

  bool get isValid =>
      width > 0 &&
      height > 0 &&
      imageWidth > 0 &&
      imageHeight > 0 &&
      left >= 0 &&
      top >= 0 &&
      right <= imageWidth &&
      bottom <= imageHeight;

  ProductBoundingBox copyWith({
    double? left,
    double? top,
    double? width,
    double? height,
    double? imageWidth,
    double? imageHeight,
  }) {
    return ProductBoundingBox(
      left: left ?? this.left,
      top: top ?? this.top,
      width: width ?? this.width,
      height: height ?? this.height,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
    );
  }
}
