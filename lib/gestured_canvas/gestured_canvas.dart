// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:neural_graph/gestured_canvas/gestures.dart';

abstract class Region {
  bool containsPoint(Offset offset);
}

class LineRegion implements Region {
  const LineRegion(
    this.p1,
    this.p2,
    this.paint,
  );
  final Offset p1;
  final Offset p2;
  final Paint paint;

  @override
  bool containsPoint(Offset offset) {
    final distance = ((p2.dx - p1.dx) * (p1.dy - offset.dy) -
                (p1.dx - offset.dx) * (p2.dy - p1.dy))
            .abs() /
        (p2 - p1).distance;
    return distance < paint.strokeWidth;
  }
}

class CircleRegion implements Region {
  const CircleRegion(
    this.c,
    this.radius,
    this.paint,
  );
  final Offset c;
  final double radius;
  final Paint paint;

  @override
  bool containsPoint(Offset offset) {
    return (offset - c).distanceSquared < radius * radius;
  }
}

class GesturedRegion {
  final Region region;
  final Key? key;
  final Gestures? gestures;

  GesturedRegion(this.region, this.key, this.gestures);
}

class GesturedCanvas {
  final Canvas canvas;
  final List<GesturedRegion> regions = [];
  final Set<GestureType> _gestureTypes = {};

  GesturedCanvas._(this.canvas, RegionContainer container) {
    container._addListener(_onEvent);
  }

  void _onEvent(RawGesture rawGesture) {
    if (!_gestureTypes.contains(rawGesture.type)) {
      return;
    }
    final offset = rawGesture.localPosition();
    if (offset == null) {
      return;
    }
    for (final region in regions.reversed) {
      final gestures = region.gestures;
      if (gestures != null &&
          gestures.gestureTypes.contains(rawGesture.type) &&
          region.region.containsPoint(offset)) {
        return gestures.consume(rawGesture);
      }
    }
  }

  void _add(Region region, Key? key, Gestures? gestures) {
    regions.add(GesturedRegion(region, key, gestures));
    if (gestures != null) {
      _gestureTypes.addAll(gestures.gestureTypes);
    }
  }

  void drawLine(Offset p1, Offset p2, Paint paint,
      {Key? key, Gestures? gestures}) {
    canvas.drawLine(p1, p2, paint);
    _add(LineRegion(p1, p2, paint), key, gestures);
  }

  void drawCircle(Offset c, double radius, Paint paint,
      {Key? key, Gestures? gestures}) {
    canvas.drawCircle(c, radius, paint);
    _add(CircleRegion(c, radius, paint), key, gestures);
  }

  void drawParagraph(Paragraph paragraph, Offset offset) {
    canvas.drawParagraph(paragraph, offset);
  }
}

class RegionContainer {
  void Function(RawGesture)? _listener;

  Future<void> _addListener(void Function(RawGesture) listener) async {
    _listener = listener;
  }

  void _emit(RawGesture event) {
    _listener?.call(event);
  }

  void dispose() {
    _listener = null;
  }

  GesturedCanvas wrapCanvas(Canvas canvas) {
    return GesturedCanvas._(canvas, this);
  }
}

class GesturedCanvasDetector extends StatefulWidget {
  final Widget Function(BuildContext context, RegionContainer regions) builder;
  final Gestures? gestures;

  const GesturedCanvasDetector({
    Key? key,
    required this.builder,
    this.gestures,
  }) : super(key: key);

  @override
  _GesturedCanvasDetectorState createState() => _GesturedCanvasDetectorState();
}

class _GesturedCanvasDetectorState extends State<GesturedCanvasDetector> {
  final RegionContainer regions = RegionContainer();

  @override
  void dispose() {
    regions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gestures = widget.gestures;
    return GestureDetector(
      onTapDown: (e) {
        gestures?.onTapDown?.call(e);
        regions._emit(RawGesture(GestureType.onTapDown, e));
      },
      onTapUp: (e) {
        gestures?.onTapUp?.call(e);
        regions._emit(RawGesture(GestureType.onTapUp, e));
      },
      onTap: () {
        gestures?.onTap?.call();
        regions._emit(RawGesture(GestureType.onTap, null));
      },
      onTapCancel: () {
        gestures?.onTapCancel?.call();
        regions._emit(RawGesture(GestureType.onTapCancel, null));
      },
      onSecondaryTap: () {
        gestures?.onSecondaryTap?.call();
        regions._emit(RawGesture(GestureType.onSecondaryTap, null));
      },
      onSecondaryTapDown: (e) {
        gestures?.onSecondaryTapDown?.call(e);
        regions._emit(RawGesture(GestureType.onSecondaryTapDown, e));
      },
      onSecondaryTapUp: (e) {
        gestures?.onSecondaryTapUp?.call(e);
        regions._emit(RawGesture(GestureType.onSecondaryTapUp, e));
      },
      onSecondaryTapCancel: () {
        gestures?.onSecondaryTapCancel?.call();
        regions._emit(RawGesture(GestureType.onSecondaryTapCancel, null));
      },
      onTertiaryTapDown: (e) {
        gestures?.onTertiaryTapDown?.call(e);
        regions._emit(RawGesture(GestureType.onTertiaryTapDown, e));
      },
      onTertiaryTapUp: (e) {
        gestures?.onTertiaryTapUp?.call(e);
        regions._emit(RawGesture(GestureType.onTertiaryTapUp, e));
      },
      onTertiaryTapCancel: () {
        gestures?.onTertiaryTapCancel?.call();
        regions._emit(RawGesture(GestureType.onTertiaryTapCancel, null));
      },
      onDoubleTapDown: (e) {
        gestures?.onDoubleTapDown?.call(e);
        regions._emit(RawGesture(GestureType.onDoubleTapDown, e));
      },
      onDoubleTap: () {
        gestures?.onDoubleTap?.call();
        regions._emit(RawGesture(GestureType.onDoubleTap, null));
      },
      onDoubleTapCancel: () {
        gestures?.onDoubleTapCancel?.call();
        regions._emit(RawGesture(GestureType.onDoubleTapCancel, null));
      },
      onLongPress: () {
        gestures?.onLongPress?.call();
        regions._emit(RawGesture(GestureType.onLongPress, null));
      },
      onLongPressStart: (e) {
        gestures?.onLongPressStart?.call(e);
        regions._emit(RawGesture(GestureType.onLongPressStart, e));
      },
      onLongPressMoveUpdate: (e) {
        gestures?.onLongPressMoveUpdate?.call(e);
        regions._emit(RawGesture(GestureType.onLongPressMoveUpdate, e));
      },
      onLongPressUp: () {
        gestures?.onLongPressUp?.call();
        regions._emit(RawGesture(GestureType.onLongPressUp, null));
      },
      onLongPressEnd: (e) {
        gestures?.onLongPressEnd?.call(e);
        regions._emit(RawGesture(GestureType.onLongPressEnd, e));
      },
      onSecondaryLongPress: () {
        gestures?.onSecondaryLongPress?.call();
        regions._emit(RawGesture(GestureType.onSecondaryLongPress, null));
      },
      onSecondaryLongPressStart: (e) {
        gestures?.onSecondaryLongPressStart?.call(e);
        regions._emit(RawGesture(GestureType.onSecondaryLongPressStart, e));
      },
      onSecondaryLongPressMoveUpdate: (e) {
        gestures?.onSecondaryLongPressMoveUpdate?.call(e);
        regions
            ._emit(RawGesture(GestureType.onSecondaryLongPressMoveUpdate, e));
      },
      onSecondaryLongPressUp: () {
        gestures?.onSecondaryLongPressUp?.call();
        regions._emit(RawGesture(GestureType.onSecondaryLongPressUp, null));
      },
      onSecondaryLongPressEnd: (e) {
        gestures?.onSecondaryLongPressEnd?.call(e);
        regions._emit(RawGesture(GestureType.onSecondaryLongPressEnd, e));
      },
      // onVerticalDragDown: (e){gestures?.onVerticalDragDown?.call(e);regions._emit(RawGesture(GestureType.onVerticalDragDown, e));},
      // onVerticalDragStart: (e){gestures?.onVerticalDragStart?.call(e);regions._emit(RawGesture(GestureType.onVerticalDragStart, e));},
      // onVerticalDragUpdate: (e){gestures?.onVerticalDragUpdate?.call(e);regions._emit(RawGesture(GestureType.onVerticalDragUpdate, e));},
      // onVerticalDragEnd: (e){gestures?.onVerticalDragEnd?.call(e);regions._emit(RawGesture(GestureType.onVerticalDragEnd, e));},
      // onVerticalDragCancel: (){gestures?.onVerticalDragCancel?.call();regions._emit(RawGesture(GestureType.onVerticalDragCancel, null));},
      // onHorizontalDragDown: (e){gestures?.onHorizontalDragDown?.call(e);regions._emit(RawGesture(GestureType.onHorizontalDragDown, e));},
      // onHorizontalDragStart: (e){gestures?.onHorizontalDragStart?.call(e);regions._emit(RawGesture(GestureType.onHorizontalDragStart, e));},
      // onHorizontalDragUpdate: (e){gestures?.onHorizontalDragUpdate?.call(e);regions._emit(RawGesture(GestureType.onHorizontalDragUpdate, e));},
      // onHorizontalDragEnd: (e){gestures?.onHorizontalDragEnd?.call(e);regions._emit(RawGesture(GestureType.onHorizontalDragEnd, e));},
      // onHorizontalDragCancel: (){gestures?.onHorizontalDragCancel?.call();regions._emit(RawGesture(GestureType.onHorizontalDragCancel, null));},
      onPanDown: (e) {
        gestures?.onPanDown?.call(e);
        regions._emit(RawGesture(GestureType.onPanDown, e));
      },
      onPanStart: (e) {
        gestures?.onPanStart?.call(e);
        regions._emit(RawGesture(GestureType.onPanStart, e));
      },
      onPanUpdate: (e) {
        gestures?.onPanUpdate?.call(e);
        regions._emit(RawGesture(GestureType.onPanUpdate, e));
      },
      onPanEnd: (e) {
        gestures?.onPanEnd?.call(e);
        regions._emit(RawGesture(GestureType.onPanEnd, e));
      },
      onPanCancel: () {
        gestures?.onPanCancel?.call();
        regions._emit(RawGesture(GestureType.onPanCancel, null));
      },
      // onScaleStart: (e){gestures?.onScaleStart?.call(e);regions._emit(RawGesture(GestureType.onScaleStart, e));},
      // onScaleUpdate: (e){gestures?.onScaleUpdate?.call(e);regions._emit(RawGesture(GestureType.onScaleUpdate, e));},
      // onScaleEnd: (e){gestures?.onScaleEnd?.call(e);regions._emit(RawGesture(GestureType.onScaleEnd, e));},
      onForcePressStart: (e) {
        gestures?.onForcePressStart?.call(e);
        regions._emit(RawGesture(GestureType.onForcePressStart, e));
      },
      onForcePressPeak: (e) {
        gestures?.onForcePressPeak?.call(e);
        regions._emit(RawGesture(GestureType.onForcePressPeak, e));
      },
      onForcePressUpdate: (e) {
        gestures?.onForcePressUpdate?.call(e);
        regions._emit(RawGesture(GestureType.onForcePressUpdate, e));
      },
      onForcePressEnd: (e) {
        gestures?.onForcePressEnd?.call(e);
        regions._emit(RawGesture(GestureType.onForcePressEnd, e));
      },
      child: widget.builder(context, regions),
    );
  }
}
