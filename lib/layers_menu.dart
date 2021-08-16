import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:neural_graph/diagram/node.dart';
import 'package:neural_graph/widgets/resizable.dart';

const _menuMap = {
  'Model': [
    'Input',
    'Output',
    'Loss',
    'Metric',
    'Optimizer',
    'Callback',
  ],
  'Layers': [
    'Convolutional',
    'Dense',
    'Recurrent',
    'Transformer',
    'Dropout',
    'Embedding',
    'Normalization',
  ],
  'Activations': ['Softmax', 'Sigmoid', 'Relu'],
  'Slice / Shape': [
    'Concat',
    'Gather',
    'Stack',
    'Tile',
    'Slice',
    'Split',
    'Reshape',
    'Traspose',
  ],
};

class LayersMenu extends HookWidget {
  const LayersMenu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final searchTerm = useTextEditingController();
    useListenable(searchTerm);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0, left: 6.0),
          child: TextField(
            controller: searchTerm,
            decoration: InputDecoration(
              suffixIcon: TextButton(
                onPressed: searchTerm.clear,
                child: searchTerm.text.isEmpty
                    ? const Icon(Icons.search, size: 22)
                    : const Icon(Icons.close, size: 22),
              ),
              suffixIconConstraints: BoxConstraints.tight(const Size(36, 36)),
              contentPadding: (Theme.of(context)
                      .inputDecorationTheme
                      .contentPadding! as EdgeInsets)
                  .copyWith(top: 10),
            ),
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: searchTerm,
            builder: (context, _) {
              final _search = searchTerm.text.toLowerCase();
              final list = _menuMap.entries
                  .map(
                    (e) => MapEntry(
                      e.key,
                      e.value
                          .where((k) => k.toLowerCase().contains(_search))
                          .toList(),
                    ),
                  )
                  .where(
                    (e) =>
                        e.key.toLowerCase().contains(_search) ||
                        e.value.isNotEmpty,
                  );
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'No matches for filter',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              String? firstSection;
              return ListView(
                padding: const EdgeInsets.only(right: 16.0),
                shrinkWrap: true,
                children: list.map((e) {
                  firstSection ??= e.key;
                  return _ListSection(
                    key: Key(e.key),
                    firstSection: firstSection!,
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
    Key? key,
    required this.firstSection,
    required this.textTheme,
    required this.e,
  }) : super(key: key);

  final String firstSection;
  final TextTheme textTheme;
  final MapEntry<String, List<String>> e;

  @override
  Widget build(BuildContext context) {
    final open = useState(true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Separator(
          size: e.key == firstSection ? 6 : 20,
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
              splashRadius: 24,
              icon: Icon(open.value
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              onPressed: () => open.value = !open.value,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 30),
            )
          ],
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: open.value ? e.value.length * 35.0 + 10 : 0,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 5),
            itemCount: e.value.length,
            itemExtent: 35,
            itemBuilder: (ctx, index) {
              final text = e.value[index];
              return Draggable<String>(
                key: Key(text),
                data: text,
                dragAnchorStrategy: pointerDragAnchorStrategy,
                feedback: NodeContainer(
                  isSelected: true,
                  child: Center(
                    child: Text(
                      text,
                      style: textTheme.subtitle1,
                    ),
                  ),
                ),
                child: FlatButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          text,
                          key: Key(text),
                          style: textTheme.subtitle1,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
