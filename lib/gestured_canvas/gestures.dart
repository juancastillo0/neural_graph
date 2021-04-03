
import 'package:flutter/material.dart';

class Gestures {
  Gestures({
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onTapCancel,
    this.onSecondaryTap,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onTertiaryTapDown,
    this.onTertiaryTapUp,
    this.onTertiaryTapCancel,
    this.onDoubleTapDown,
    this.onDoubleTap,
    this.onDoubleTapCancel,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressUp,
    this.onLongPressEnd,
    this.onSecondaryLongPress,
    this.onSecondaryLongPressStart,
    this.onSecondaryLongPressMoveUpdate,
    this.onSecondaryLongPressUp,
    this.onSecondaryLongPressEnd,
    // this.onVerticalDragDown,
    // this.onVerticalDragStart,
    // this.onVerticalDragUpdate,
    // this.onVerticalDragEnd,
    // this.onVerticalDragCancel,
    // this.onHorizontalDragDown,
    // this.onHorizontalDragStart,
    // this.onHorizontalDragUpdate,
    // this.onHorizontalDragEnd,
    // this.onHorizontalDragCancel,
    this.onPanDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    // this.onScaleStart,
    // this.onScaleUpdate,
    // this.onScaleEnd,
    this.onForcePressStart,
    this.onForcePressPeak,
    this.onForcePressUpdate,
    this.onForcePressEnd,
  });

  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTap;
  final GestureTapCancelCallback? onTapCancel;
  final GestureTapCallback? onSecondaryTap;
  final GestureTapDownCallback? onSecondaryTapDown;
  final GestureTapUpCallback? onSecondaryTapUp;
  final GestureTapCancelCallback? onSecondaryTapCancel;
  final GestureTapDownCallback? onTertiaryTapDown;
  final GestureTapUpCallback? onTertiaryTapUp;
  final GestureTapCancelCallback? onTertiaryTapCancel;
  final GestureTapDownCallback? onDoubleTapDown;
  final GestureTapCallback? onDoubleTap;
  final GestureTapCancelCallback? onDoubleTapCancel;
  final GestureLongPressCallback? onLongPress;
  final GestureLongPressStartCallback? onLongPressStart;
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;
  final GestureLongPressUpCallback? onLongPressUp;
  final GestureLongPressEndCallback? onLongPressEnd;
  final GestureLongPressCallback? onSecondaryLongPress;
  final GestureLongPressStartCallback? onSecondaryLongPressStart;
  final GestureLongPressMoveUpdateCallback? onSecondaryLongPressMoveUpdate;
  final GestureLongPressUpCallback? onSecondaryLongPressUp;
  final GestureLongPressEndCallback? onSecondaryLongPressEnd;
  // final GestureDragDownCallback? onVerticalDragDown;
  // final GestureDragStartCallback? onVerticalDragStart;
  // final GestureDragUpdateCallback? onVerticalDragUpdate;
  // final GestureDragEndCallback? onVerticalDragEnd;
  // final GestureDragCancelCallback? onVerticalDragCancel;
  // final GestureDragDownCallback? onHorizontalDragDown;
  // final GestureDragStartCallback? onHorizontalDragStart;
  // final GestureDragUpdateCallback? onHorizontalDragUpdate;
  // final GestureDragEndCallback? onHorizontalDragEnd;
  // final GestureDragCancelCallback? onHorizontalDragCancel;
  final GestureDragDownCallback? onPanDown;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final GestureDragCancelCallback? onPanCancel;
  // final GestureScaleStartCallback? onScaleStart;
  // final GestureScaleUpdateCallback? onScaleUpdate;
  // final GestureScaleEndCallback? onScaleEnd;
  final GestureForcePressStartCallback? onForcePressStart;
  final GestureForcePressPeakCallback? onForcePressPeak;
  final GestureForcePressUpdateCallback? onForcePressUpdate;
  final GestureForcePressEndCallback? onForcePressEnd;

  late final Set<GestureType> gestureTypes = {
    if (onTapDown != null) GestureType.onTapDown,
    if (onTapUp != null) GestureType.onTapUp,
    if (onTap != null) GestureType.onTap,
    if (onTapCancel != null) GestureType.onTapCancel,
    if (onSecondaryTap != null) GestureType.onSecondaryTap,
    if (onSecondaryTapDown != null) GestureType.onSecondaryTapDown,
    if (onSecondaryTapUp != null) GestureType.onSecondaryTapUp,
    if (onSecondaryTapCancel != null) GestureType.onSecondaryTapCancel,
    if (onTertiaryTapDown != null) GestureType.onTertiaryTapDown,
    if (onTertiaryTapUp != null) GestureType.onTertiaryTapUp,
    if (onTertiaryTapCancel != null) GestureType.onTertiaryTapCancel,
    if (onDoubleTapDown != null) GestureType.onDoubleTapDown,
    if (onDoubleTap != null) GestureType.onDoubleTap,
    if (onDoubleTapCancel != null) GestureType.onDoubleTapCancel,
    if (onLongPress != null) GestureType.onLongPress,
    if (onLongPressStart != null) GestureType.onLongPressStart,
    if (onLongPressMoveUpdate != null) GestureType.onLongPressMoveUpdate,
    if (onLongPressUp != null) GestureType.onLongPressUp,
    if (onLongPressEnd != null) GestureType.onLongPressEnd,
    if (onSecondaryLongPress != null) GestureType.onSecondaryLongPress,
    if (onSecondaryLongPressStart != null) GestureType.onSecondaryLongPressStart,
    if (onSecondaryLongPressMoveUpdate != null) GestureType.onSecondaryLongPressMoveUpdate,
    if (onSecondaryLongPressUp != null) GestureType.onSecondaryLongPressUp,
    if (onSecondaryLongPressEnd != null) GestureType.onSecondaryLongPressEnd,
    // if (onVerticalDragDown != null) GestureType.onVerticalDragDown,
    // if (onVerticalDragStart != null) GestureType.onVerticalDragStart,
    // if (onVerticalDragUpdate != null) GestureType.onVerticalDragUpdate,
    // if (onVerticalDragEnd != null) GestureType.onVerticalDragEnd,
    // if (onVerticalDragCancel != null) GestureType.onVerticalDragCancel,
    // if (onHorizontalDragDown != null) GestureType.onHorizontalDragDown,
    // if (onHorizontalDragStart != null) GestureType.onHorizontalDragStart,
    // if (onHorizontalDragUpdate != null) GestureType.onHorizontalDragUpdate,
    // if (onHorizontalDragEnd != null) GestureType.onHorizontalDragEnd,
    // if (onHorizontalDragCancel != null) GestureType.onHorizontalDragCancel,
    if (onPanDown != null) GestureType.onPanDown,
    if (onPanStart != null) GestureType.onPanStart,
    if (onPanUpdate != null) GestureType.onPanUpdate,
    if (onPanEnd != null) GestureType.onPanEnd,
    if (onPanCancel != null) GestureType.onPanCancel,
    // if (onScaleStart != null) GestureType.onScaleStart,
    // if (onScaleUpdate != null) GestureType.onScaleUpdate,
    // if (onScaleEnd != null) GestureType.onScaleEnd,
    if (onForcePressStart != null) GestureType.onForcePressStart,
    if (onForcePressPeak != null) GestureType.onForcePressPeak,
    if (onForcePressUpdate != null) GestureType.onForcePressUpdate,
    if (onForcePressEnd != null) GestureType.onForcePressEnd,
  };

  void consume<T>(RawGesture<T> rawGesture) {
    switch (rawGesture.type) {
      case GestureType.onTapDown:
        onTapDown?.call(rawGesture.event as TapDownDetails);
        break;
      case GestureType.onTapUp:
        onTapUp?.call(rawGesture.event as TapUpDetails);
        break;
      case GestureType.onTap:
        onTap?.call();
        break;
      case GestureType.onTapCancel:
        onTapCancel?.call();
        break;
      case GestureType.onSecondaryTap:
        onSecondaryTap?.call();
        break;
      case GestureType.onSecondaryTapDown:
        onSecondaryTapDown?.call(rawGesture.event as TapDownDetails);
        break;
      case GestureType.onSecondaryTapUp:
        onSecondaryTapUp?.call(rawGesture.event as TapUpDetails);
        break;
      case GestureType.onSecondaryTapCancel:
        onSecondaryTapCancel?.call();
        break;
      case GestureType.onTertiaryTapDown:
        onTertiaryTapDown?.call(rawGesture.event as TapDownDetails);
        break;
      case GestureType.onTertiaryTapUp:
        onTertiaryTapUp?.call(rawGesture.event as TapUpDetails);
        break;
      case GestureType.onTertiaryTapCancel:
        onTertiaryTapCancel?.call();
        break;
      case GestureType.onDoubleTapDown:
        onDoubleTapDown?.call(rawGesture.event as TapDownDetails);
        break;
      case GestureType.onDoubleTap:
        onDoubleTap?.call();
        break;
      case GestureType.onDoubleTapCancel:
        onDoubleTapCancel?.call();
        break;
      case GestureType.onLongPress:
        onLongPress?.call();
        break;
      case GestureType.onLongPressStart:
        onLongPressStart?.call(rawGesture.event as LongPressStartDetails);
        break;
      case GestureType.onLongPressMoveUpdate:
        onLongPressMoveUpdate?.call(rawGesture.event as LongPressMoveUpdateDetails);
        break;
      case GestureType.onLongPressUp:
        onLongPressUp?.call();
        break;
      case GestureType.onLongPressEnd:
        onLongPressEnd?.call(rawGesture.event as LongPressEndDetails);
        break;
      case GestureType.onSecondaryLongPress:
        onSecondaryLongPress?.call();
        break;
      case GestureType.onSecondaryLongPressStart:
        onSecondaryLongPressStart?.call(rawGesture.event as LongPressStartDetails);
        break;
      case GestureType.onSecondaryLongPressMoveUpdate:
        onSecondaryLongPressMoveUpdate?.call(rawGesture.event as LongPressMoveUpdateDetails);
        break;
      case GestureType.onSecondaryLongPressUp:
        onSecondaryLongPressUp?.call();
        break;
      case GestureType.onSecondaryLongPressEnd:
        onSecondaryLongPressEnd?.call(rawGesture.event as LongPressEndDetails);
        break;
      // case GestureType.onVerticalDragDown:
      //   onVerticalDragDown?.call(rawGesture.event as DragDownDetails);
      //   break;
      // case GestureType.onVerticalDragStart:
      //   onVerticalDragStart?.call(rawGesture.event as DragStartDetails);
      //   break;
      // case GestureType.onVerticalDragUpdate:
      //   onVerticalDragUpdate?.call(rawGesture.event as DragUpdateDetails);
      //   break;
      // case GestureType.onVerticalDragEnd:
      //   onVerticalDragEnd?.call(rawGesture.event as DragEndDetails);
      //   break;
      // case GestureType.onVerticalDragCancel:
      //   onVerticalDragCancel?.call();
      //   break;
      // case GestureType.onHorizontalDragDown:
      //   onHorizontalDragDown?.call(rawGesture.event as DragDownDetails);
      //   break;
      // case GestureType.onHorizontalDragStart:
      //   onHorizontalDragStart?.call(rawGesture.event as DragStartDetails);
      //   break;
      // case GestureType.onHorizontalDragUpdate:
      //   onHorizontalDragUpdate?.call(rawGesture.event as DragUpdateDetails);
      //   break;
      // case GestureType.onHorizontalDragEnd:
      //   onHorizontalDragEnd?.call(rawGesture.event as DragEndDetails);
      //   break;
      // case GestureType.onHorizontalDragCancel:
      //   onHorizontalDragCancel?.call();
      //   break;
      case GestureType.onPanDown:
        onPanDown?.call(rawGesture.event as DragDownDetails);
        break;
      case GestureType.onPanStart:
        onPanStart?.call(rawGesture.event as DragStartDetails);
        break;
      case GestureType.onPanUpdate:
        onPanUpdate?.call(rawGesture.event as DragUpdateDetails);
        break;
      case GestureType.onPanEnd:
        onPanEnd?.call(rawGesture.event as DragEndDetails);
        break;
      case GestureType.onPanCancel:
        onPanCancel?.call();
        break;
      // case GestureType.onScaleStart:
      //   onScaleStart?.call(rawGesture.event as ScaleStartDetails);
      //   break;
      // case GestureType.onScaleUpdate:
      //   onScaleUpdate?.call(rawGesture.event as ScaleUpdateDetails);
      //   break;
      // case GestureType.onScaleEnd:
      //   onScaleEnd?.call(rawGesture.event as ScaleEndDetails);
      //   break;
      case GestureType.onForcePressStart:
        onForcePressStart?.call(rawGesture.event as ForcePressDetails);
        break;
      case GestureType.onForcePressPeak:
        onForcePressPeak?.call(rawGesture.event as ForcePressDetails);
        break;
      case GestureType.onForcePressUpdate:
        onForcePressUpdate?.call(rawGesture.event as ForcePressDetails);
        break;
      case GestureType.onForcePressEnd:
        onForcePressEnd?.call(rawGesture.event as ForcePressDetails);
        break;
    }
  }
}



class RawGesture<T> {
  final GestureType type;
  final T event;

  RawGesture(this.type, this.event);

  Offset? localPosition() {
    switch (type) {
      case GestureType.onTapDown:
        return (event as TapDownDetails).localPosition;
      case GestureType.onTapUp:
        return (event as TapUpDetails).localPosition;
      // case GestureType.onTap:
      //   onTap?.call();
      //   break;
      // case GestureType.onTapCancel:
      //   onTapCancel?.call();
      //   break;
      // case GestureType.onSecondaryTap:
      //   onSecondaryTap?.call();
      //   break;
      case GestureType.onSecondaryTapDown:
        return (event as TapDownDetails).localPosition;
      case GestureType.onSecondaryTapUp:
        return (event as TapUpDetails).localPosition;
      // case GestureType.onSecondaryTapCancel:
      //   onSecondaryTapCancel?.call();
      //   break;
      case GestureType.onTertiaryTapDown:
        return (event as TapDownDetails).localPosition;
      case GestureType.onTertiaryTapUp:
        return (event as TapUpDetails).localPosition;
      // case GestureType.onTertiaryTapCancel:
      //   onTertiaryTapCancel?.call();
      //   break;
      case GestureType.onDoubleTapDown:
        return (event as TapDownDetails).localPosition;
      // case GestureType.onDoubleTap:
      //   onDoubleTap?.call();
      //   break;
      // case GestureType.onDoubleTapCancel:
      //   onDoubleTapCancel?.call();
      //   break;
      // case GestureType.onLongPress:
      //   onLongPress?.call();
      //   break;
      case GestureType.onLongPressStart:
        return (event as LongPressStartDetails).localPosition;
      case GestureType.onLongPressMoveUpdate:
        return (event as LongPressMoveUpdateDetails).localPosition;
      // case GestureType.onLongPressUp:
      //   onLongPressUp?.call();
      //   break;
      case GestureType.onLongPressEnd:
        return (event as LongPressEndDetails).localPosition;
      // case GestureType.onSecondaryLongPress:
      //   onSecondaryLongPress?.call();
      //   break;
      case GestureType.onSecondaryLongPressStart:
        return (event as LongPressStartDetails).localPosition;
      case GestureType.onSecondaryLongPressMoveUpdate:
        return (event as LongPressMoveUpdateDetails).localPosition;
      // case GestureType.onSecondaryLongPressUp:
      //   onSecondaryLongPressUp?.call();
      //   break;
      case GestureType.onSecondaryLongPressEnd:
        return (event as LongPressEndDetails).localPosition;
      // case GestureType.onVerticalDragDown:
      //   return (event as DragDownDetails).localPosition;
      // case GestureType.onVerticalDragStart:
      //   return (event as DragStartDetails).localPosition;
      // case GestureType.onVerticalDragUpdate:
      //   return (event as DragUpdateDetails).localPosition;
      // case GestureType.onVerticalDragEnd:
      //   return (event as DragEndDetails).localPosition;
      // case GestureType.onVerticalDragCancel:
      //   onVerticalDragCancel?.call();
      //   break;
      // case GestureType.onHorizontalDragDown:
      //   return (event as DragDownDetails).localPosition;
      // case GestureType.onHorizontalDragStart:
      //   return (event as DragStartDetails).localPosition;
      // case GestureType.onHorizontalDragUpdate:
      //   return (event as DragUpdateDetails).localPosition;
      // case GestureType.onHorizontalDragEnd:
      //   return (event as DragEndDetails).localPosition;
      // case GestureType.onHorizontalDragCancel:
      //   onHorizontalDragCancel?.call();
      //   break;
      case GestureType.onPanDown:
        return (event as DragDownDetails).localPosition;
      case GestureType.onPanStart:
        return (event as DragStartDetails).localPosition;
      case GestureType.onPanUpdate:
        return (event as DragUpdateDetails).localPosition;
      // case GestureType.onPanEnd:
      //   return (event as DragEndDetails).localPosition;
      // case GestureType.onPanCancel:
      //   onPanCancel?.call();
      //   break;
      // case GestureType.onScaleStart:
      //   return (event as ScaleStartDetails).localFocalPoint;
      // case GestureType.onScaleUpdate:
      //   return (event as ScaleUpdateDetails).localFocalPoint;
      // case GestureType.onScaleEnd:
      //   return (event as ScaleEndDetails).localPosition;
      case GestureType.onForcePressStart:
        return (event as ForcePressDetails).localPosition;
      case GestureType.onForcePressPeak:
        return (event as ForcePressDetails).localPosition;
      case GestureType.onForcePressUpdate:
        return (event as ForcePressDetails).localPosition;
      case GestureType.onForcePressEnd:
        return (event as ForcePressDetails).localPosition;
      default:
        return null;
    }
  }

}

enum GestureType {
  onTapDown,
  onTapUp,
  onTap,
  onTapCancel,
  onSecondaryTap,
  onSecondaryTapDown,
  onSecondaryTapUp,
  onSecondaryTapCancel,
  onTertiaryTapDown,
  onTertiaryTapUp,
  onTertiaryTapCancel,
  onDoubleTapDown,
  onDoubleTap,
  onDoubleTapCancel,
  onLongPress,
  onLongPressStart,
  onLongPressMoveUpdate,
  onLongPressUp,
  onLongPressEnd,
  onSecondaryLongPress,
  onSecondaryLongPressStart,
  onSecondaryLongPressMoveUpdate,
  onSecondaryLongPressUp,
  onSecondaryLongPressEnd,
  // onVerticalDragDown,
  // onVerticalDragStart,
  // onVerticalDragUpdate,
  // onVerticalDragEnd,
  // onVerticalDragCancel,
  // onHorizontalDragDown,
  // onHorizontalDragStart,
  // onHorizontalDragUpdate,
  // onHorizontalDragEnd,
  // onHorizontalDragCancel,
  onPanDown,
  onPanStart,
  onPanUpdate,
  onPanEnd,
  onPanCancel,
  // onScaleStart,
  // onScaleUpdate,
  // onScaleEnd,
  onForcePressStart,
  onForcePressPeak,
  onForcePressUpdate,
  onForcePressEnd,
}
