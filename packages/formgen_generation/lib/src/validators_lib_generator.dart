import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:formgen/formgen.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

class ValidatorsLibGenerator implements Builder {
  final BuilderOptions options;

  ValidatorsLibGenerator(this.options);

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': ['all_validators.dart']
    };
  }

  static AssetId _allFileOutput(BuildStep buildStep) {
    return AssetId(
      buildStep.inputId.package,
      p.join('lib', 'all_validators.dart'),
    );
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final allClasses = <ClassElement>[];

    await for (final input in buildStep.findAssets(Glob('lib/**.dart'))) {
      final library = await buildStep.resolver.libraryFor(input);
      final classesInLibrary = LibraryReader(library).classes;

      allClasses.addAll(
        classesInLibrary.where(
          (element) => const TypeChecker.fromRuntime(Validate)
              .hasAnnotationOfExact(element),
        ),
      );
    }

    try {
      // final outputAsset =
      //     AssetId(buildStep.inputId.package, 'lib/global.validations.dart');

      String out = '''
import 'package:formgen/formgen.dart';
${allClasses.map((e) => "import '${e.source.uri}';").toSet().join()}

// ignore: avoid_classes_with_only_static_members
class Validators {
  static const typeMap = <Type, Validator>{
    ${allClasses.map((e) {
        return '${e.name}: validator${e.name},';
      }).join()}
  };

  ${allClasses.map((e) {
        return 'static const validator${e.name} = Validator(validate${e.name});';
      }).join()}

  static Validator<T, Validation<T, Object>>? validator<T>() {
    final validator = typeMap[T];
    return validator as Validator<T, Validation<T, Object>>?;
  }
  
  static Validation<T, Object>? validate<T>(T value) {
    final validator = typeMap[T];
    return validator?.validate(value) as Validation<T, Object>?;
  }
}
''';
      try {
        out = DartFormatter().format(out);
      } catch (_) {}

      await buildStep.writeAsString(_allFileOutput(buildStep), out);
    } catch (e, s) {
      print('$e $s');
    }
  }
}
