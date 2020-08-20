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
  const CodeGenHelper({this.language});

  final ProgrammingLanguage language;

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

  String get sep => language.isJs ? ":" : "=";

  String layerName(String name) {
    final _initial = language.isJs ? "{" : "";
    return "$_initial name $sep $name";
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

  String closeArgs() => language.isJs ? "}" : "";

  String firstOrList<T>(List<T> items) =>
      items.length == 1 ? items[0].toString() : items.toString();

  String get _defineKeyword => language.isJs ? "const " : "";
  String get _outputSuffix => language.isJs ? 'Output' : '_output';
  String get _typeCastTensor => language.isJs ? " as SymbolicTensor " : "";

  String _defineOutput(String name) {
    return "$_defineKeyword $name$_outputSuffix";
  }

  String applyOne(String name) {
    if (language.isJs) {
      return "${_defineOutput(name)} $name.apply([%=self.firstInput()%]) $_typeCastTensor";
    } else {
      return "${_defineOutput(name)} $name([%=self.firstInput())";
    }
  }
}
