import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:styled_widget/styled_widget.dart';

const _iconSize = 22.0;
const _scrollIconPadding = const EdgeInsets.all(0);

class MultiScrollController {
  MultiScrollController({vertical, horizontal})
      : this.vertical = vertical ?? ScrollController(),
        this.horizontal = horizontal ?? ScrollController();
  final ScrollController vertical;
  final ScrollController horizontal;

  void onDrag(Offset delta) {
    if (delta.dx != 0) {
      final hp = horizontal.position;
      final dx = (horizontal.offset - delta.dx).clamp(0, hp.maxScrollExtent);
      horizontal.jumpTo(dx);
    }

    if (delta.dy != 0) {
      final vp = vertical.position;
      final dy = (vertical.offset - delta.dy).clamp(0, vp.maxScrollExtent);
      vertical.jumpTo(dy);
    }
  }

  void dispose() {
    vertical.dispose();
    horizontal.dispose();
  }
}

class MultiScrollable extends StatefulWidget {
  const MultiScrollable({this.builder, Key key}) : super(key: key);
  final Widget Function(
    BuildContext context,
    MultiScrollController controller,
  ) builder;

  @override
  _MultiScrollableState createState() => _MultiScrollableState();
}

class _MultiScrollableState extends State<MultiScrollable> {
  final controller = MultiScrollController();

  @override
  void initState() {
    Future.delayed(Duration.zero, () => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

class ButtonScrollbar extends StatelessWidget {
  const ButtonScrollbar({
    Key key,
    @required this.controller,
    this.horizontal = false,
  }) : super(key: key);

  final ScrollController controller;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    if (!controller.hasClients ||
        controller.position?.viewportDimension == null)
      return SizedBox(width: 0, height: 0);

    final children = [
      FlatButton(
        child: Icon(horizontal ? Icons.arrow_left : Icons.arrow_drop_up),
        onPressed: null,
        padding: _scrollIconPadding,
      ).constrained(maxHeight: _iconSize, maxWidth: _iconSize),
      MultiScrollbar(
        controller: controller,
        horizontal: horizontal,
      ).expanded(),
      FlatButton(
        child: Icon(horizontal ? Icons.arrow_right : Icons.arrow_drop_down),
        onPressed: null,
        padding: _scrollIconPadding,
      ).constrained(maxHeight: _iconSize, maxWidth: _iconSize)
    ];

    return ConstrainedBox(
      constraints: BoxConstraints.loose(
        horizontal
            ? Size(double.infinity, _iconSize)
            : Size(_iconSize, double.infinity),
      ),
      child: Flex(
        direction: horizontal ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
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
  Widget build(ctx) {
    final position = controller.position;
    final offset = useState(0.0);
    final maxScrollExtent = useState(position.maxScrollExtent);

    maxScrollExtent.value =
        position.maxScrollExtent + position.viewportDimension;

    useEffect(() {
      final _listener = () => offset.value = controller.offset;
      controller.addListener(_listener);
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
            horizontal ? SizedBox(width: top) : SizedBox(height: top),
            SizedBox(
              child: Container(color: Colors.black),
              height: horizontal ? double.infinity : handleSize,
              width: horizontal ? handleSize : double.infinity,
            ).gestures(
              dragStartBehavior: DragStartBehavior.down,
              onPanUpdate: (DragUpdateDetails p) {
                final _delta = horizontal ? p.delta.dx : p.delta.dy;
                final _offset = (controller.offset + _delta / rate)
                    .clamp(0, position.maxScrollExtent);
                controller.jumpTo(_offset);
              },
            ),
          ],
        );
      },
    );
  }
}
