import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

enum ResizeHorizontal { left, right, both }
enum ResizeVertical { top, bottom, both }

const _handleSize = 10.0;

class Resizable extends StatefulWidget {
  final ResizeHorizontal horizontal;
  final double defaultWidth;
  final double minWidth;

  final ResizeVertical vertical;
  final double defaultHeight;
  final double minHeight;

  final Widget child;
  final Widget handle;

  Resizable({
    this.handle,
    this.horizontal,
    this.defaultWidth,
    this.child,
    this.minWidth,
    this.vertical,
    this.defaultHeight,
    this.minHeight,
  });

  @override
  _ResizableState createState() => _ResizableState();
}

class _ResizableState extends State<Resizable> {
  double _width;
  double _height;

  @override
  void initState() {
    _width = widget.defaultWidth;
    _height = widget.defaultHeight;
    super.initState();
  }

  _updateWidth(bool proportional) => (DragUpdateDetails details) {
        setState(() {
          if (proportional)
            _width += details.delta.dx;
          else
            _width -= details.delta.dx;
        });
      };

  _updateHeight(bool proportional) => (DragUpdateDetails details) {
        setState(() {
          if (proportional)
            _height += details.delta.dy;
          else
            _height -= details.delta.dy;
        });
      };

  @override
  Widget build(ctx) {
    if (widget.vertical != null) {
      final isBottom = widget.vertical == ResizeVertical.bottom;
      final handle = GestureDetector(
        child: widget.handle ?? const Divider(height: _handleSize),
        onVerticalDragUpdate: _updateHeight(isBottom),
        behavior: HitTestBehavior.translucent,
        dragStartBehavior: DragStartBehavior.down,
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isBottom) handle,
          widget.child.expanded(),
          if (isBottom) handle
        ],
      ).constrained(height: _height);
    } else {
      final isRight = widget.horizontal == ResizeHorizontal.right;
      final handle = GestureDetector(
        child: widget.handle ?? const VerticalDivider(width: _handleSize),
        onHorizontalDragUpdate: _updateWidth(isRight),
        behavior: HitTestBehavior.translucent,
        dragStartBehavior: DragStartBehavior.down,
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isRight) handle,
          widget.child.expanded(),
          if (isRight) handle
        ],
      ).constrained(width: _width);
    }
  }
}
