import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum ResizeHorizontal { left, right, both }
enum ResizeVertical { top, bottom, both }

class Resizable extends StatefulWidget {
  final ResizeHorizontal? horizontal;
  final double? defaultWidth;
  final double? minWidth;

  final ResizeVertical? vertical;
  final double? defaultHeight;
  final double? minHeight;

  final Widget child;
  final Widget? handle;

  const Resizable({
    this.handle,
    this.horizontal,
    this.defaultWidth,
    required this.child,
    this.minWidth,
    this.vertical,
    this.defaultHeight,
    this.minHeight,
  });

  @override
  _ResizableState createState() => _ResizableState();
}

class _ResizableState extends State<Resizable> {
  double? _width;
  double? _height;

  @override
  void initState() {
    _width = widget.defaultWidth;
    _height = widget.defaultHeight;
    super.initState();
  }

  void Function(DragUpdateDetails) _updateSize(
    bool proportional,
    bool horizontal,
  ) {
    return horizontal
        ? (DragUpdateDetails details) {
            setState(() {
              _width = _width! +
                  (proportional ? details.delta.dx : -details.delta.dx);
            });
          }
        : (DragUpdateDetails details) {
            setState(() {
              _height = _height! +
                  (proportional ? details.delta.dy : -details.delta.dy);
            });
          };
  }

  @override
  Widget build(BuildContext ctx) {
    if (widget.vertical != null) {
      final isBottom = widget.vertical == ResizeVertical.bottom;
      final handle = GestureDetector(
        onVerticalDragUpdate: _updateSize(isBottom, false),
        behavior: HitTestBehavior.translucent,
        dragStartBehavior: DragStartBehavior.down,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeUpDown,
          child: widget.handle ?? const Separator(),
        ),
      );

      return SizedBox(
        height: _height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isBottom) handle,
            Expanded(child: widget.child),
            if (isBottom) handle
          ],
        ),
      );
    } else {
      final isRight = widget.horizontal == ResizeHorizontal.right;
      final handle = GestureDetector(
        onHorizontalDragUpdate: _updateSize(isRight, true),
        behavior: HitTestBehavior.translucent,
        dragStartBehavior: DragStartBehavior.down,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: widget.handle ?? const Separator(vertical: true),
        ),
      );

      return SizedBox(
        width: _width,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRight) handle,
            Expanded(child: widget.child),
            if (isRight) handle
          ],
        ),
      );
    }
  }
}

class Separator extends StatelessWidget {
  const Separator({
    this.size = 14,
    this.color = Colors.black12,
    this.vertical = false,
    this.thickness = 1,
  });

  final double size;
  final double thickness;
  final Color color;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final margin = (size - thickness) / 2;

    if (vertical) {
      return Container(
        color: color,
        margin: EdgeInsets.symmetric(horizontal: margin),
        constraints: BoxConstraints(maxWidth: thickness),
      );
    } else {
      return Container(
        color: color,
        margin: EdgeInsets.symmetric(vertical: margin),
        constraints: BoxConstraints(maxHeight: thickness),
      );
    }
  }
}
