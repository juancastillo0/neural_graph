import 'dart:math';

import 'package:flutter/material.dart';
import 'package:neural_graph/widgets/scrollable.dart';

String enumToString(dynamic d) => d.toString().split(".")[1];

class DefaultForm extends StatelessWidget {
  const DefaultForm({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MultiScrollable(
        builder: (ctx, controller) {
          final theme = Theme.of(ctx);
          return SingleChildScrollView(
            controller: controller.vertical,
            child: Theme(
              data: theme.copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                isDense: true,
                // contentPadding: EdgeInsets.only(top: 3, bottom: 3, left: 10),
                labelStyle: TextStyle(fontSize: 18),
              )),
              child: DefaultTextStyle(
                style: theme.textTheme.bodyText1.copyWith(fontSize: 16),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: FocusTraversalGroup(
                    child: Form(
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FormFieldValue<T> {
  final TextEditingController controller;
  final FocusNode focusNode;
  String error;
  final T Function() _getValue;
  final Function(T) _setValue;

  T get value => _getValue();
  set value(T newValue) => _setValue(newValue);

  FormFieldValue(
      {@required T Function() getValue,
      @required Function(T) setValue,
      FocusNode focusNode,
      TextEditingController controller})
      : controller = controller ?? TextEditingController(),
        focusNode = focusNode ?? FocusNode(),
        _getValue = getValue,
        _setValue = setValue;

  void dispose() {
    focusNode.dispose();
    controller.dispose();
  }
}

TableRow tableRow({
  String name,
  String description,
  Widget field,
  double maxWidth = 250,
  double maxHeight,
  double minHeight = 52,
}) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(name),
      ),
      Tooltip(
        message: description,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: const Icon(Icons.info_outline),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: maxWidth,
            height: max(minHeight, maxHeight ?? 0),
            child: field,
          ),
        ),
      ),
    ],
  );
}
