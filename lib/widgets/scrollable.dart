import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:styled_widget/styled_widget.dart';

const _iconSize = 24.0;
const _scrollIconPadding = const EdgeInsets.all(2);

class MultiScrollable extends StatefulWidget {
  const MultiScrollable({this.builder, Key key}) : super(key: key);
  final Widget Function(BuildContext context,
      {ScrollController verticalController,
      ScrollController horizontalController}) builder;

  @override
  _MultiScrollableState createState() => _MultiScrollableState();
}

class _MultiScrollableState extends State<MultiScrollable> {
  final vController = ScrollController();
  final hController = ScrollController();

  void scrollListener() {
    // print(vController.offset);
    // print(vController.position);
  }

  @override
  void initState() {
    vController.addListener(scrollListener);
    Future.delayed(Duration.zero, () => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    vController.removeListener(scrollListener);
    vController.dispose();
    hController.dispose();
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
            widget
                .builder(
                  context,
                  horizontalController: hController,
                  verticalController: vController,
                )
                .expanded(),
            ButtonScrollbar(vController: vController)
          ],
        ).expanded(),
        ButtonScrollbar(vController: hController, horizontal: true),
      ],
    );
  }
}

class ButtonScrollbar extends StatelessWidget {
  const ButtonScrollbar({
    Key key,
    @required this.vController,
    this.horizontal = false,
  }) : super(key: key);

  final ScrollController vController;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    if (!vController.hasClients ||
        vController.position?.viewportDimension == null)
      return SizedBox(width: 0, height: 0);

    final children = [
      FlatButton(
        child: Icon(horizontal ? Icons.arrow_left : Icons.arrow_drop_up),
        onPressed: null,
        padding: _scrollIconPadding,
      ).constrained(maxHeight: _iconSize, maxWidth: _iconSize),
      MultiScrollbar(
        controller: vController,
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
