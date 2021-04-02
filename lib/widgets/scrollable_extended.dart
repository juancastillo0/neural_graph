import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neural_graph/graph_canvas/store_graph_canvas.dart';
import 'package:neural_graph/root_store.dart';
import 'package:neural_graph/widgets/scrollable.dart';

class CustomScrollGestures extends HookWidget {
  const CustomScrollGestures({
    Key? key,
    required this.child,
    required this.canvas,
    this.allowDrag = true,
  }) : super(key: key);
  final Widget child;
  final bool allowDrag;
  final GraphCanvasStore canvas;

  @override
  Widget build(BuildContext ctx) {
    final prevPoint = useState(const Offset(0, 0));
    final initScale = useState(canvas.scale);

    return LayoutBuilder(
      builder: (ctx, box) {
        void onScaleUpdate(ScaleUpdateDetails d) {
          if (d.scale != 1) {
            // print(
            //     "canvas.toCanvasOffset(d.focalPoint) ${canvas.toCanvasOffset2(d.focalPoint)}");
            // print(
            //     "canvas.toCanvasOffset(prevPoint.value) ${canvas.toCanvasOffset2(prevPoint.value)}");
            final _p = canvas.toCanvasOffset(prevPoint.value);
            final _prev = canvas.scale;
            canvas.onScale(d.scale * initScale.value);
            final _p2 = canvas.toCanvasOffset(prevPoint.value);
            print("$_p $_p2");
            final center = Offset(box.maxWidth / 2, box.maxHeight / 2);
            final fromCenter =
                (prevPoint.value - center) * _prev / canvas.scale;
            canvas.onDrag((_p2 - _p) * canvas.scale);
            prevPoint.value = d.localFocalPoint;
          } else {
            canvas.onDrag(d.localFocalPoint - prevPoint.value);
            prevPoint.value = d.localFocalPoint;
          }
        }

        return GestureDetector(
          onScaleStart: (details) {
            initScale.value = canvas.scale;
            prevPoint.value = details.localFocalPoint;
          },
          dragStartBehavior: DragStartBehavior.down,
          onScaleUpdate: allowDrag ? onScaleUpdate : null,
          child: SingleChildScrollView(
            controller: canvas.horizontal,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SingleChildScrollView(
              controller: canvas.vertical,
              physics: const NeverScrollableScrollPhysics(),
              child: Observer(
                builder: (ctx) {
                  final multiplier = canvas.scale;
                  final _height = canvas.size.height * multiplier;
                  final _width = canvas.size.width * multiplier;

                  return SizedBox(
                    height: _height,
                    width: _width,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: 0.0,
                        minHeight: 0.0,
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: Transform.translate(
                          offset: canvas.translateOffset,
                          child: Transform.scale(
                            scale: canvas.scale,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class MouseScrollListener extends StatefulWidget {
  const MouseScrollListener({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);
  final GraphCanvasStore controller;
  final Widget child;

  @override
  _MouseScrollListenerState createState() => _MouseScrollListenerState();
}

const _kScrollCoefWindows = 3.5;

double _scrollCoef() {
  if (kIsWeb) {
    return 1.0;
  } else if (Platform.isWindows) {
    return _kScrollCoefWindows;
  } else {
    return 1.0;
  }
}

class _MouseScrollListenerState extends State<MouseScrollListener> {
  final _focusNode = FocusNode();
  bool isShiftPressed = false;
  bool isCtrlPressed = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      if (isCtrlPressed) {
        final newScale =
            widget.controller.scale - pointerSignal.scrollDelta.dy / 400;
        widget.controller.onScale(newScale);
      } else if (isShiftPressed) {
        widget.controller
            .onDrag(Offset(-pointerSignal.scrollDelta.dy * _scrollCoef(), 0));
      } else {
        widget.controller
            .onDrag(Offset(0, -pointerSignal.scrollDelta.dy * _scrollCoef()));
      }
    }
  }

  void _onKey(RawKeyEvent event) {
    setState(() {
      isShiftPressed = event.data.isShiftPressed;
      isCtrlPressed = event.data.isControlPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _focusNode.requestFocus(),
      onExit: (_) => _focusNode.unfocus(
          disposition: UnfocusDisposition.previouslyFocusedChild),
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: _focusNode,
        onKey: _onKey,
        child: Listener(
          onPointerSignal: _onPointerSignal,
          child: widget.child,
        ),
      ),
    );
  }
}
