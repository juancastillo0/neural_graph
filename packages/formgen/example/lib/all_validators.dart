import 'package:formgen/formgen.dart';
import 'package:formgen_example/model.dart';

class Validators {
  static const typeMap = <Type, Validator>{
    FormTest: validatorFormTest,
    NestedField: validatorNestedField,
  };

  static const validatorFormTest = Validator(validateFormTest);
  static const validatorNestedField = Validator(validateNestedField);

  static Validator<T, Validation<T, Object>>? validator<T>() {
    final validator = typeMap[T];
    return validator as Validator<T, Validation<T, Object>>?;
  }

  static Validation<T, Object>? validate<T>(T value) {
    final validator = typeMap[T];
    return validator?.validate(value) as Validation<T, Object>?;
  }
}
