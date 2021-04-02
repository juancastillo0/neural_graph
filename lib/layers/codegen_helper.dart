import 'package:flutter/foundation.dart';
import 'package:neural_graph/common/extensions.dart';
import 'package:neural_graph/layers/layers.dart';

enum ProgrammingLanguage { javascript, python, rust }

extension ProgrammingLanguageExt on ProgrammingLanguage {
  bool get isJs => this == ProgrammingLanguage.javascript;
  bool get isPython => this == ProgrammingLanguage.python;
  bool get isRust => this == ProgrammingLanguage.rust;
}

extension StringExtension on String {
  String firstToUpperCase() =>
      length == 0 ? "" : this[0].toUpperCase() + substring(1);
}

class CodeGenHelper {
  CodeGenHelper({required this.language});

  final ProgrammingLanguage language;

  final buffer = StringBuffer();

  int _spaces = 0;

  void withTab(void Function() fn) {
    _spaces += 2;
    buffer.write(" " * _spaces);
    fn();
    _spaces -= 2;
  }

  void write(Object object) {
    if (_spaces != 0) {
      buffer.write(object.toString().replaceAll("\n", "\n${" " * _spaces}"));
    } else {
      buffer.write(object);
    }
  }

  String layerTypeName(String name) {
    if (language.isJs) {
      return name;
    } else {
      final ans = <String>[];
      bool prevIsNum = false;

      for (String c in name.firstToUpperCase().split("")) {
        prevIsNum = false;
        if (int.tryParse(c) != null) {
          prevIsNum = true;
        } else if (prevIsNum) {
          c = c.toUpperCase();
        }
        ans.add(c);
      }
      return ans.join();
    }
  }

  String argName(String name) {
    if (language.isJs) {
      return name;
    } else {
      final ans = <String>[];
      for (final c in name.split('')) {
        if (c.toUpperCase() == c) {
          ans.add("_${c.toLowerCase()}");
        } else {
          ans.add(c);
        }
      }
      return ans.join();
    }
  }

  // ignore: avoid_positional_boolean_parameters
  String printBool(bool boolean) => language.isPython
      ? boolean.toString().firstToUpperCase()
      : boolean.toString();

  String openArgs() => language.isJs ? "{" : "";

  String closeArgs() => language.isJs ? "}" : "";

  String firstOrList<T>(List<T> items) =>
      items.length == 1 ? items[0].toString() : items.toString();

  String get defineKeyword => language.isJs ? "const " : "";
  String get outputSuffix => language.isJs ? 'Output' : '_output';

  String defineOutput(String name) {
    return "$defineKeyword$name$outputSuffix =";
  }

  String defineName(String name) {
    return "$defineKeyword$name =";
  }

  String get sep => language.isJs ? ":" : "=";

  String setName(String name) {
    return 'name$sep "$name"';
  }

  String setActivation(Activation activation) {
    return (activation != null)
        ? 'activation$sep "${argName(toEnumString(activation))}"'
        : "";
  }

  String get typeCastTensor => language.isJs ? " as SymbolicTensor" : "";

  String applyOne(String name, String inputName) {
    if (language.isJs) {
      return "${defineOutput(name)} $name.apply($inputName$outputSuffix)$typeCastTensor;";
    } else {
      return "${defineOutput(name)} $name($inputName$outputSuffix);";
    }
  }

  String applyMany(String name, List<String> inputNames) {
    if (language.isJs) {
      return "${defineOutput(name)} $name.apply(${inputNames.map((ii) => '$ii$outputSuffix').join(',')}) $typeCastTensor";
    } else {
      return "${defineOutput(name)} $name(${inputNames.map((ii) => '$ii$outputSuffix').join(',')})";
    }
  }
}
