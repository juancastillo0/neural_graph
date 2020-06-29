import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:neural_graph/main.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:neural_graph/common/extensions.dart';

const _iconSize = 24.0;
const _scrollIconPadding = EdgeInsets.all(0);

class MultiScrollController {
  MultiScrollController(
      {ScrollController vertical,
      ScrollController horizontal,
      void Function(double) setScale,
      @required this.context})
      : vertical = vertical ?? ScrollController(),
        horizontal = horizontal ?? ScrollController(),
        _setScale = setScale;
  final ScrollController vertical;
  final ScrollController horizontal;
  // TODO: better scale management.
  final void Function(double) _setScale;
  final BuildContext context;

  void onDrag(Offset delta) {
    if (delta.dx != 0) {
      final hp = horizontal.position;
      final dx =
          (horizontal.offset - delta.dx).clamp(0, hp.maxScrollExtent) as double;
      horizontal.jumpTo(dx);
    }

    if (delta.dy != 0) {
      final vp = vertical.position;
      final dy =
          (vertical.offset - delta.dy).clamp(0, vp.maxScrollExtent) as double;
      vertical.jumpTo(dy);
    }
  }

  void onScale(double scale) {
    if (_setScale != null) {
      _setScale(scale.clamp(0.4, 2.5) as double);
      horizontal.jumpTo(horizontal.offset + 0.0001);
      vertical.jumpTo(vertical.offset + 0.0001);
    }
  }

  Offset toCanvasOffset(Offset offset) {
    final bounds = context.globalPaintBounds;
    return offset -
        bounds.topLeft +
        Offset(
          horizontal.offset,
          vertical.offset,
        );
  }

  void dispose() {
    vertical.dispose();
    horizontal.dispose();
  }
}

class MultiScrollable extends StatefulWidget {
  const MultiScrollable({this.builder, Key key, this.setScale})
      : super(key: key);
  final Widget Function(
    BuildContext context,
    MultiScrollController controller,
  ) builder;
  final void Function(double) setScale;

  @override
  _MultiScrollableState createState() => _MultiScrollableState();
}

class _MultiScrollableState extends State<MultiScrollable> with RouteAware {
  MultiScrollController controller;

  @override
  void initState() {
    controller = MultiScrollController(
      setScale: widget.setScale,
      context: context,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    controller.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.builder(context, controller).expanded(),
            ButtonScrollbar(controller: controller.vertical)
          ],
        ).expanded(),
        ButtonScrollbar(
          controller: controller.horizontal,
          horizontal: true,
        ),
      ],
    );
  }
}

class ButtonScrollbar extends HookWidget {
  const ButtonScrollbar({
    Key key,
    @required this.controller,
    this.horizontal = false,
  }) : super(key: key);

  final ScrollController controller;
  final bool horizontal;

  void onPressedScrollButtonStart() {
    controller.jumpTo(max(controller.offset - 20, 0));
  }

  void onPressedScrollButtonEnd() {
    controller.jumpTo(
      min(controller.offset + 20, controller.position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPressedButton = useState(false);
    if (!controller.hasClients ||
        controller.position?.viewportDimension == null) {
      return const SizedBox(width: 0, height: 0);
    }

    Future onLongPressStartForward(LongPressStartDetails _) async {
      isPressedButton.value = true;
      while (isPressedButton.value &&
          controller.offset < controller.position.maxScrollExtent) {
        await controller.animateTo(
          min(controller.offset + 50, controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
      }
    }

    Future onLongPressStartBackward(LongPressStartDetails _) async {
      isPressedButton.value = true;
      while (isPressedButton.value && controller.offset > 0) {
        await controller.animateTo(
          max(controller.offset - 50, 0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
      }
    }

    final children = [
      GestureDetector(
        onLongPressStart: onLongPressStartBackward,
        onLongPressEnd: (details) => isPressedButton.value = false,
        child: FlatButton(
          onPressed: onPressedScrollButtonStart,
          padding: _scrollIconPadding,
          child: Icon(horizontal ? Icons.arrow_left : Icons.arrow_drop_up),
        ).constrained(maxHeight: _iconSize, maxWidth: _iconSize),
      ),
      MultiScrollbar(
        controller: controller,
        horizontal: horizontal,
      ).expanded(),
      GestureDetector(
        onLongPressStart: onLongPressStartForward,
        onLongPressEnd: (details) => isPressedButton.value = false,
        child: FlatButton(
          onPressed: onPressedScrollButtonEnd,
          padding: _scrollIconPadding,
          child: Icon(horizontal ? Icons.arrow_right : Icons.arrow_drop_down),
        ).constrained(maxHeight: _iconSize, maxWidth: _iconSize),
      )
    ];

    return ConstrainedBox(
      constraints: BoxConstraints.loose(
        horizontal
            ? const Size(double.infinity, _iconSize)
            : const Size(_iconSize, double.infinity),
      ),
      child: Flex(
        direction: horizontal ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}

class MultiScrollbar extends HookWidget {
  const MultiScrollbar({
    @required this.controller,
    this.horizontal = false,
    Key key,
  }) : super(key: key);
  final ScrollController controller;
  final bool horizontal;

  @override
  Widget build(BuildContext ctx) {
    final position = controller.position;
    final offset = useState(0.0);
    final maxScrollExtent = useState(position.maxScrollExtent);
    final hovering = useState(false);
    final dragging = useState(false);

    maxScrollExtent.value =
        position.maxScrollExtent + position.viewportDimension;

    useEffect(() {
      void _listener() {
        final position = controller.position;
        maxScrollExtent.value =
            position.maxScrollExtent + position.viewportDimension;
        offset.value = controller.offset;
      }

      controller.position.addListener(_listener);
      return () => controller.removeListener(_listener);
    }, [controller]);

    return LayoutBuilder(
      builder: (ctx, box) {
        final maxSize = horizontal ? box.maxWidth : box.maxHeight;
        final handleSize =
            maxSize * position.viewportDimension / maxScrollExtent.value;
        final rate = (maxSize - handleSize) / position.maxScrollExtent;
        final top = rate * offset.value;

        return Flex(
          direction: horizontal ? Axis.horizontal : Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (horizontal) SizedBox(width: top) else SizedBox(height: top),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontal ? 0 : 3,
                vertical: horizontal ? 3 : 0,
              ),
              child: MouseRegion(
                onEnter: (_) => hovering.value = true,
                onExit: (_) => hovering.value = false,
                child: SizedBox(
                  height: horizontal ? double.infinity : handleSize,
                  width: horizontal ? handleSize : double.infinity,
                  child: Container(
                    color: hovering.value || dragging.value
                        ? Colors.black26
                        : Colors.black12,
                  ),
                ).gestures(
                  dragStartBehavior: DragStartBehavior.down,
                  onPanDown: (_) => dragging.value = true,
                  onPanEnd: (_) => dragging.value = false,
                  onPanUpdate: (DragUpdateDetails p) {
                    final _delta = horizontal ? p.delta.dx : p.delta.dy;
                    final _offset = (controller.offset + _delta / rate)
                        .clamp(0, position.maxScrollExtent) as double;
                    controller.jumpTo(_offset);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
