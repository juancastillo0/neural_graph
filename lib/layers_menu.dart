import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:neural_graph/widgets/resizable.dart';
import 'package:neural_graph/widgets/scrollable.dart';

const _menuMap = {
  'Model': [
    "Input",
    "Loss",
    "Metric",
    "Optimizer",
    "Callback",
  ],
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
  Widget build(BuildContext ctx) {
    final textTheme = Theme.of(ctx).textTheme;
    final searchTerm = useTextEditingController();
    useListenable(searchTerm);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0, left: 6.0),
          child: TextField(
            controller: searchTerm,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: searchTerm.text.isEmpty
                    ? const Icon(Icons.search)
                    : const Icon(Icons.close),
                onPressed: searchTerm.clear,
              ),
            ),
          ),
        ),
        Expanded(
          child: MultiScrollable(
            builder: (ctx, controller) {
              final firstSection = _menuMap.keys.first;
              return ListView(
                controller: controller.vertical,
                padding: const EdgeInsets.only(bottom: 15),
                shrinkWrap: true,
                children: _menuMap.entries.map((e) {
                  return _ListSection(
                    firstSection: firstSection,
                    textTheme: textTheme,
                    e: e,
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ListSection extends HookWidget {
  const _ListSection({
    Key key,
    @required this.firstSection,
    @required this.textTheme,
    @required this.e,
  }) : super(key: key);

  final String firstSection;
  final TextTheme textTheme;
  final MapEntry<String, List<String>> e;

  @override
  Widget build(BuildContext context) {
    final open = useState(true);
    return Column(
      children: [
        Separator(
          size: 20,
          color: e.key == firstSection ? Colors.transparent : Colors.black26,
        ),
        Row(
          children: [
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                e.key,
                style: textTheme.headline6,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: Icon(open.value
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_up),
              onPressed: () => open.value = !open.value,
              constraints: const BoxConstraints(minWidth: 36, minHeight:30),
            )
          ],
        ),
        const SizedBox(height: 6),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            vertical: 5,
          ),
          itemBuilder: (ctx, index) {
            final text = e.value[index];
            return FlatButton(
              onPressed: () {},
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  key: Key(text),
                  style: textTheme.subtitle1,
                ),
              ),
            );
          },
          itemCount: e.value.length,
          itemExtent: 35,
        ),
      ],
    );
  }
}
