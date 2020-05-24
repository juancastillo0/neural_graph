import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:styled_widget/styled_widget.dart';

const _iconSize = 28.0;

class MultiScrollable extends StatefulWidget {
  const MultiScrollable({this.builder, Key key}) : super(key: key);
  final Widget Function(BuildContext context, ScrollController controller)
      builder;

  @override
  _MultiScrollableState createState() => _MultiScrollableState();
}

class _MultiScrollableState extends State<MultiScrollable> {
  final vController = ScrollController();

  void scrollListener() {
    print(vController.offset);
    print(vController.position);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.builder(context, vController).expanded(),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            const FlatButton(
              child: const Icon(Icons.arrow_drop_up),
              onPressed: null,
              padding: const EdgeInsets.all(2),
            ).constrained(maxHeight: _iconSize),
            Expanded(
              child: ((!vController.hasClients ||
                      vController.position?.viewportDimension == null)
                  ? Container()
                  : MultiScrollbar(controller: vController)),
            ),
            const FlatButton(
              child: const Icon(Icons.arrow_drop_down),
              onPressed: null,
              padding: const EdgeInsets.all(2),
            ).constrained(maxHeight: _iconSize)
          ],
        ).constrained(maxWidth: _iconSize)
      ],
    );
  }
}

class MultiScrollbar extends HookWidget {
  const MultiScrollbar({@required this.controller, Key key}) : super(key: key);
  final ScrollController controller;

  @override
  Widget build(ctx) {
    final position = controller.position;
    final offset = useState(0.0);
    useEffect(() {
      final _listener = () {
        offset.value = controller.offset;
      };
      controller.addListener(_listener);
      return () => controller.removeListener(_listener);
    }, [controller]);

    return LayoutBuilder(
      builder: (ctx, box) {
        final handleHeight = box.maxHeight /
            position.maxScrollExtent *
            position.viewportDimension;
        final rate = (box.maxHeight - handleHeight) / position.maxScrollExtent;

        final top = rate * offset.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: top),
            SizedBox(
              child: Container(color: Colors.black),
              height: handleHeight,
            ).gestures(
              dragStartBehavior: DragStartBehavior.down,
              onPanUpdate: (p) {
                final _offset = (controller.offset + p.delta.dy / rate)
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
