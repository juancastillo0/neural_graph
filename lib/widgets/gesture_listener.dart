import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class GlobalKeyboardListener {
  static final focusNode = FocusNode();
  static final _keyboardController = StreamController<RawKeyEvent>.broadcast();
  static final keyboardStream = _keyboardController.stream;
  static final _tapController = StreamController<TapDownDetails>.broadcast();
  static final tapStream = _tapController.stream;

  static final gestures = {
    AllowMultipleGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<AllowMultipleGestureRecognizer>(
      () => AllowMultipleGestureRecognizer(),
      (instance) {
        instance.onTapDown = GlobalKeyboardListener._onTapDown;
      },
    )
  };

  static void _onKey(RawKeyEvent event) {
    _keyboardController.add(event);
  }

  static void _onTapDown(TapDownDetails event) {
    _tapController.add(event);
  }

  static Widget wrapper({required Widget child}) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: GlobalKeyboardListener.focusNode,
      onKey: GlobalKeyboardListener._onKey,
      child: RawGestureDetector(
        behavior: HitTestBehavior.translucent,
        gestures: GlobalKeyboardListener.gestures,
        child: child,
      ),
    );
  }
}

class AllowMultipleGestureRecognizer extends TapGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
