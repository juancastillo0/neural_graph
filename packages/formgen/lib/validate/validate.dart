export 'validate_annotations.dart';

// class ValidationError {
//   const ValidationError._();

//   factory ValidationError({
//     required String property,
//     required Object? value,
//     required String errorCode,
//     required String message,
//     Object? validationParam,
//     Validation? nestedValidation,
//   }) = ValidationErrorSingle;

//   static ValidationError nested<T, F>(Validation<T, F> validation) =>
//       ValidationErrorNested<T, F>(validation);

// }

class ValidationError {
  // TODO: final F fieldId;

  final String property;
  final Object? value;
  final String errorCode;
  final Object? validationParam;
  final String message;
  final Validation? nestedValidation;

  const ValidationError({
    required this.property,
    required this.value,
    required this.errorCode,
    required this.message,
    this.validationParam,
    this.nestedValidation,
  });

  @override
  String toString() {
    return '$errorCode${validationParam == null ? '' : '(${validationParam})'}: '
        '$message. $property${value == null ? '' : ' = $value'}';
  }

  static ValidationError? fromNested(String property, Validation validation) {
    return validation.hasErrors
        ? ValidationError(
            errorCode: 'Validate.nested',
            message: '',
            property: property,
            value: validation.value,
            nestedValidation: validation,
          )
        : null;
    // return this.hasErrors ? ValidationError.nested(this) : null;
  }
}

// class ValidationErrorNested<T, F> extends ValidationError {
//   final Validation<T, F> validation;

//   ValidationErrorNested(this.validation) : super._();
// }

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

  ValidationError? toError({required String property}) {
    return ValidationError.fromNested(property, this);
  }
}

abstract class Validatable<T, F> {
  Validator<T, F> get validator;
}

abstract class Validator<T, F> {
  Validation<T, F> validate(T value);
}
