import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neural_graph/graph_canvas/store_graph_canvas.dart';
import 'package:neural_graph/root_store.dart';
import 'package:neural_graph/widgets/scrollable.dart';

class CustomScrollGestures extends HookWidget {
  const CustomScrollGestures({
    Key key,
    @required this.child,
    @required this.controller,
    this.allowDrag = true,
  }) : super(key: key);
  final Widget child;
  final MultiScrollController controller;
  final bool allowDrag;

  @override
  Widget build(BuildContext ctx) {
    final graphCanvas = useRoot().graphCanvas;
    final prevPoint = useState(const Offset(0, 0));
    final initScale = useState(graphCanvas.scale);

    return LayoutBuilder(
      builder: (ctx, box) {
        void onScaleUpdate(ScaleUpdateDetails d) {
          if (d.scale != 1) {
            // print(
            //     "graphCanvas.toCanvasOffset(d.focalPoint) ${graphCanvas.toCanvasOffset2(d.focalPoint)}");
            // print(
            //     "graphCanvas.toCanvasOffset(prevPoint.value) ${graphCanvas.toCanvasOffset2(prevPoint.value)}");
            final _p = graphCanvas.toCanvasOffset(prevPoint.value);
            final _prev = graphCanvas.scale;
            controller.onScale(d.scale * initScale.value);
            final _p2 = graphCanvas.toCanvasOffset(prevPoint.value);
            print("$_p $_p2");
            final center = Offset(box.maxWidth / 2, box.maxHeight / 2);
            final fromCenter =
                (prevPoint.value - center) * _prev / graphCanvas.scale;
            controller.onDrag((_p2 - _p) * graphCanvas.scale);
            prevPoint.value = d.localFocalPoint;
          } else {
            controller.onDrag(d.localFocalPoint - prevPoint.value);
            prevPoint.value = d.localFocalPoint;
          }
        }

        return GestureDetector(
          onScaleStart: (details) {
            initScale.value = graphCanvas.scale;
            prevPoint.value = details.localFocalPoint;
          },
          dragStartBehavior: DragStartBehavior.down,
          onScaleUpdate: allowDrag ? onScaleUpdate : null,
          child: SingleChildScrollView(
            controller: controller.horizontal,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SingleChildScrollView(
              controller: controller.vertical,
              physics: const NeverScrollableScrollPhysics(),
              child: Observer(
                builder: (ctx) {
                  final multiplier = graphCanvas.scale;
                  final _height = graphCanvas.size.height * multiplier;
                  final _width = graphCanvas.size.width * multiplier;

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
                          offset: graphCanvas.translateOffset,
                          child: Transform.scale(
                            scale: graphCanvas.scale,
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
    Key key,
    @required this.controller,
    @required this.child,
  }) : super(key: key);
  final MultiScrollController controller;
  final Widget child;

  @override
  _MouseScrollListenerState createState() => _MouseScrollListenerState();
}

class _MouseScrollListenerState extends State<MouseScrollListener> {
  final _focusNode = FocusNode();
  bool isShiftPressed = false;
  bool isCtrlPressed = false;
  GraphCanvasStore graphCanvas = RootStore.instance.graphCanvas;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      if (isCtrlPressed) {
        final newScale = graphCanvas.scale - pointerSignal.scrollDelta.dy / 400;
        widget.controller.onScale(newScale);
      } else if (isShiftPressed) {
        widget.controller.onDrag(Offset(-pointerSignal.scrollDelta.dy, 0));
      } else {
        widget.controller.onDrag(Offset(0, -pointerSignal.scrollDelta.dy));
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
