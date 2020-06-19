import 'package:flutter/material.dart';

extension GlobalPaintBoundsExt on BuildContext {
  Rect get globalPaintBounds {
    final renderObject = findRenderObject();
    final translation = renderObject?.getTransformTo(null)?.getTranslation();
    if (translation != null && renderObject.paintBounds != null) {
      return renderObject.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}
