import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:neural_graph/graph_canvas/store_graph_canvas.dart';
import 'package:neural_graph/main.dart';

const _iconSize = 24.0;
const _scrollIconPadding = EdgeInsets.all(0);

class MultiScrollable extends StatefulWidget {
  const MultiScrollable({
    this.child,
    Key? key,
    this.vertical,
    this.horizontal,
  }) : super(key: key);
  final Widget? child;
  final ScrollController? vertical;
  final ScrollController? horizontal;

  @override
  _MultiScrollableState createState() => _MultiScrollableState();
}

class _MultiScrollableState extends State<MultiScrollable> with RouteAware {
  double? innerWidth;
  double? innerHeight;

  @override
  void initState() {
    SchedulerBinding.instance!.addPostFrameCallback((_) => setState(() {}));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    SchedulerBinding.instance!
                        .addPostFrameCallback((timeStamp) {
                      if (innerWidth != box.maxWidth ||
                          innerHeight != box.maxHeight) {
                        setState(() {
                          innerWidth = box.maxWidth;
                          innerHeight = box.maxHeight;
                        });
                      }
                    });
                    return widget.child!;
                  },
                ),
              ),
              ButtonScrollbar(
                controller: widget.vertical,
                maxSize: innerHeight,
              ),
            ],
          ),
        ),
        ButtonScrollbar(
          controller: widget.horizontal,
          horizontal: true,
          maxSize: innerWidth,
        ),
      ],
    );
  }
}

class ButtonScrollbar extends HookWidget {
  const ButtonScrollbar({
    Key? key,
    required this.controller,
    required this.maxSize,
    this.horizontal = false,
  }) : super(key: key);

  final ScrollController? controller;
  final bool horizontal;
  final double? maxSize;

  void onPressedScrollButtonStart() {
    controller!.jumpTo(max(controller!.offset - 20, 0));
  }

  void onPressedScrollButtonEnd() {
    controller!.jumpTo(
      min(controller!.offset + 20, controller!.position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPressedButton = useState(false);
    if (controller == null ||
        !controller!.hasClients ||
        controller!.position.viewportDimension == null ||
        controller!.position.viewportDimension < maxSize!) {
      return const SizedBox(width: 0, height: 0);
    }

    Future onLongPressStartForward(LongPressStartDetails _) async {
      isPressedButton.value = true;
      while (isPressedButton.value &&
          controller!.offset < controller!.position.maxScrollExtent) {
        await controller!.animateTo(
          min(controller!.offset + 50, controller!.position.maxScrollExtent),
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
      }
    }

    Future onLongPressStartBackward(LongPressStartDetails _) async {
      isPressedButton.value = true;
      while (isPressedButton.value && controller!.offset > 0) {
        await controller!.animateTo(
          max(controller!.offset - 50, 0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
      }
    }

    final children = [
      GestureDetector(
        onLongPressStart: onLongPressStartBackward,
        onLongPressEnd: (details) => isPressedButton.value = false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: _iconSize,
            maxWidth: _iconSize,
          ),
          child: FlatButton(
            onPressed: onPressedScrollButtonStart,
            padding: _scrollIconPadding,
            child: Icon(horizontal ? Icons.arrow_left : Icons.arrow_drop_up),
          ),
        ),
      ),
      Expanded(
        child: MultiScrollbar(
          controller: controller,
          horizontal: horizontal,
        ),
      ),
      GestureDetector(
        onLongPressStart: onLongPressStartForward,
        onLongPressEnd: (details) => isPressedButton.value = false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: _iconSize,
            maxWidth: _iconSize,
          ),
          child: FlatButton(
            onPressed: onPressedScrollButtonEnd,
            padding: _scrollIconPadding,
            child: Icon(horizontal ? Icons.arrow_right : Icons.arrow_drop_down),
          ),
        ),
      )
    ];

    return ConstrainedBox(
      constraints: BoxConstraints.loose(
        horizontal
            ? Size(maxSize ?? double.infinity, _iconSize)
            : Size(_iconSize, maxSize ?? double.infinity),
      ),
      child: Flex(
        direction: horizontal ? Axis.horizontal : Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}

class MultiScrollbar extends HookWidget {
  const MultiScrollbar({
    required this.controller,
    this.horizontal = false,
    Key? key,
  }) : super(key: key);
  final ScrollController? controller;
  final bool horizontal;

  @override
  Widget build(BuildContext ctx) {
    useListenable(controller!);
    final position = controller!.position;
    final offset = controller!.offset;
    final scrollExtent = position.maxScrollExtent + position.viewportDimension;

    return LayoutBuilder(
      builder: (ctx, box) {
        final maxSize = horizontal ? box.maxWidth : box.maxHeight;
        final handleSize = maxSize * position.viewportDimension / scrollExtent;
        final rate = (maxSize - handleSize) / position.maxScrollExtent;
        final top = rate * offset;

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
              child: _ScrollHandle(
                horizontal: horizontal,
                handleSize: handleSize,
                controller: controller,
                rate: rate,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScrollHandle extends HookWidget {
  const _ScrollHandle({
    Key? key,
    required this.horizontal,
    required this.handleSize,
    required this.controller,
    required this.rate,
  }) : super(key: key);

  final bool horizontal;
  final double handleSize;
  final ScrollController? controller;
  final double rate;

  @override
  Widget build(BuildContext context) {
    final position = controller!.position;
    final hovering = useState(false);
    final dragging = useState(false);

    return MouseRegion(
      onEnter: (_) => hovering.value = true,
      onExit: (_) => hovering.value = false,
      child: GestureDetector(
        dragStartBehavior: DragStartBehavior.down,
        onPanDown: (_) => dragging.value = true,
        onPanEnd: (_) => dragging.value = false,
        onPanUpdate: (DragUpdateDetails p) {
          final _delta = horizontal ? p.delta.dx : p.delta.dy;
          final _offset = (controller!.offset + _delta / rate)
              .clamp(0.0, position.maxScrollExtent);
          controller!.jumpTo(_offset);
        },
        child: SizedBox(
          height: horizontal ? double.infinity : handleSize,
          width: horizontal ? handleSize : double.infinity,
          child: Container(
            color: hovering.value || dragging.value
                ? Colors.black26
                : Colors.black12,
          ),
        ),
      ),
    );
  }
}
