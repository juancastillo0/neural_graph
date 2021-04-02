import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show HookWidget, useState;
import 'package:neural_graph/common/extensions.dart';

// @freezed
// class SelectOption{
//   factory SelectOption.enums()
// }

class ButtonSelect<T> extends HookWidget {
  const ButtonSelect({
    Key? key,
    required this.options,
    required this.selected,
    required this.onChange,
    this.asString,
  }) : super(key: key);

  final Iterable<T> options;
  final T selected;
  final String Function(T)? asString;
  final void Function(T) onChange;

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx);
    final isDropdown = useState(false);
    final checkedShouldBeDropdown = useState(false);
    double? buttonTop;

    String _asString(T e) => asString == null ? e.toString() : asString!(e);

    if (isDropdown.value) {
      return Align(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: DropdownButton<T>(
            value: selected,
            items: options.map((e) {
              final s = _asString(e);
              return DropdownMenuItem<T>(
                value: e,
                child: Text(s),
              );
            }).toList(),
            onChanged: (v) => onChange(v!),
          ),
        ),
      );
    }

    return Visibility(
      // TODO: can be calculate when we need a dropdown?
      visible: options.length <= 3 || checkedShouldBeDropdown.value,
      maintainState: true,
      child: ButtonBar(
        alignment: MainAxisAlignment.center,
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
        buttonPadding: EdgeInsets.zero,
        children: options.map((e) {
          final s = _asString(e);

          return FlatButton(
            key: Key(s),
            onPressed: () => onChange(e),
            color: e == selected ? theme.primaryColor : null,
            child: Builder(builder: (ctx) {
              SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
                // print("Text ${ctx.size} ${ctx.globalPaintBounds}");
                if (buttonTop == null) {
                  buttonTop = ctx.globalPaintBounds!.top;
                  return;
                }
                if (!checkedShouldBeDropdown.value) {
                  if (buttonTop != ctx.globalPaintBounds!.top) {
                    isDropdown.value = true;
                  }
                  checkedShouldBeDropdown.value = true;
                }
              });
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(s),
              );
            }),
          );
        }).toList(),
      ),
    );
  }
}
