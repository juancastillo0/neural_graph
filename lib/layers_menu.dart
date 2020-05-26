import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:neural_graph/widgets/scrollable.dart';
import 'package:styled_widget/styled_widget.dart';

const _menuMap = {
  'Model': ["Input", "Loss", "Metric", "Optimizer", "Callback"],
  'Layers': [
    "Convolutional",
    "Dense",
    "Recurrent",
    "Transformer",
    "Dropout",
    "Embedding",
    "Normalization",
  ],
  'Activations': ["Softmax", "Sigmoid", "Relu"],
  "Slice / Shape": [
    "Concat",
    "Gather",
    "Stack",
    "Tile",
    "Slice",
    "Split",
    "Reshape",
    "Traspose",
  ],
};

class LayersMenu extends HookWidget {
  const LayersMenu({Key key}) : super(key: key);
  @override
  Widget build(ctx) {
    final textTheme = Theme.of(ctx).textTheme;

    return Container(
      constraints: BoxConstraints.loose(Size(double.infinity, 200)),
      decoration: BoxDecoration(border: Border.all(width: 1)),
      child: MultiScrollable(
        builder: (ctx, {verticalController, horizontalController}) => ListView(
          controller: verticalController,
          shrinkWrap: true,
          children: _menuMap.entries.map((e) {
            return Column(
              children: [
                Text(e.key, style: textTheme.headline6),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  itemBuilder: (ctx, index) {
                    return Text(
                      e.value[index],
                      key: Key(index.toString()),
                      style: textTheme.subtitle1,
                    );
                  },
                  itemCount: e.value.length,
                  itemExtent: 35,
                ),
              ],
            ).padding(top: 8).border(top: 1, color: Colors.black26);
          }).toList(),
        ),
      ),
    );
  }
}
