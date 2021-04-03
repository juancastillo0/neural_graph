import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DefaultForm extends HookWidget {
  const DefaultForm({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(() => ScrollController());
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return SingleChildScrollView(
            controller: controller,
            child: Theme(
              data: theme.copyWith(
                  // inputDecorationTheme: const InputDecorationTheme(
                  //   isDense: true,
                  //   // contentPadding: EdgeInsets.only(top: 3, bottom: 3, left: 10),
                  //   labelStyle: TextStyle(fontSize: 18),
                  // ),
                  ),
              child: DefaultTextStyle(
                style: theme.textTheme.bodyText1!.copyWith(),
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

class DefaultFormTable extends StatelessWidget {
  final List<TableRow> children;

  const DefaultFormTable({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.symmetric(
        inside: const BorderSide(
          width: 10,
          style: BorderStyle.none,
        ),
      ),
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FixedColumnWidth(30),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: children,
    );
  }
}

class FormFieldValue<T> {
  final TextEditingController controller;
  final FocusNode focusNode;
  String? error;
  final T Function() get;
  final Function(T) set;

  T get value => get();
  set value(T newValue) => set(newValue);

  FormFieldValue({
    required this.get,
    required this.set,
    FocusNode? focusNode,
    TextEditingController? controller,
  })  : controller = controller ?? TextEditingController(),
        focusNode = focusNode ?? FocusNode();

  void dispose() {
    focusNode.dispose();
    controller.dispose();
  }
}

TableRow tableRow({
  required String name,
  String? description,
  Widget? field,
  double maxWidth = 250,
  double minHeight = 38,
}) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(name),
      ),
      IconButton(
        onPressed: () {},
        tooltip: description,
        splashRadius: 24,
        icon: const Icon(Icons.info_outline, size: 18),
      ),
      SizedBox(
        height: minHeight,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: maxWidth,
              child: field,
            ),
          ),
        ),
      ),
    ],
  );
}
