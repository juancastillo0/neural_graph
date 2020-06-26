import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show HookWidget;

// @freezed
// class SelectOption{
//   factory SelectOption.enums()
// }

class ButtonSelect<T> extends HookWidget {
  const ButtonSelect({
    Key key,
    @required this.options,
    @required this.selected,
    @required this.onChange,
    this.asString,
  }) : super(key: key);

  final Iterable<T> options;
  final T selected;
  final String Function(T) asString;
  final void Function(T) onChange;

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx);
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      buttonPadding: EdgeInsets.zero,
      children: options.map((e) {
        final s = asString == null ? e.toString() : asString(e);
        return FlatButton(
          key: Key(s),
          onPressed: () => onChange(e),
          color: e == selected ? theme.primaryColor : null,
          child: Text(s),
        );
      }).toList(),
    );
  }
}
