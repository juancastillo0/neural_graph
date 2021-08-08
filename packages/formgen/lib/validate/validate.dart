export 'validate_annotations.dart';


class ValidationError {
  // TODO: final F fieldId;

  final String property;
  final Object? value;
  final String errorCode;
  final Object? validationParam;
  final String message;
  final List<ValidationError>? children;

  const ValidationError({
    required this.property,
    required this.value,
    required this.errorCode,
    required this.message,
    this.validationParam,
    this.children,
  });

  @override
  String toString() {
    return '$errorCode${validationParam == null ? '' : '(${validationParam})'}: '
        '$message. $property${value == null ? '' : ' = $value'}';
  }
}

class Validated<T> {
  const Validated._(this.value);
  final T value;
}

abstract class Validation<T, F> {
  const Validation();

  Map<F, List<ValidationError>> get errorsMap;
  T get value;
  Object get fields;

  Iterable<ValidationError> get allErrors => errorsMap.values.expand((e) => e);

  int get numErrors =>
      errorsMap.values.fold(0, (_num, errors) => _num + errors.length);
  bool get hasErrors => allErrors.isNotEmpty;
  bool get isValid => !hasErrors;

  // TODO: faster impl
  // int get numErrors;
  // bool get hasErrors => numErrors > 0;

  Validated<T>? get validated => isValid ? Validated._(value) : null;
}

abstract class Validatable<T, F> {
  Validator<T, F> get validator;
}

abstract class Validator<T, F> {
  Validation<T, F> validate(T value);
}
