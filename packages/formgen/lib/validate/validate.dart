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
    return '$errorCode${validationParam == null ? '' : '(${validationParam})'}:'
        ' $message. $property${value == null ? '' : ' = $value'}';
  }

  static ValidationError? fromNested(String property, Validation validation) {
    return validation.hasErrors
        ? ValidationError(
            errorCode: 'Validate.nested',
            // ignore: missing_whitespace_between_adjacent_strings
            message: 'Found ${validation.numErrors} error'
                '{${validation.numErrors > 1 ? 's' : ''} in $property',
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
  Validation(Map<F, List<ValidationError>> errorsMap)
      : errorsMap = Map.unmodifiable(errorsMap),
        numErrors = computeNumErrors(errorsMap.values.expand((e) => e));

  static int computeNumErrors(Iterable<ValidationError> errors) {
    return errors.fold(
      0,
      (_num, error) => _num + (error.nestedValidation?.numErrors ?? 1),
    );
  }

  final Map<F, List<ValidationError>> errorsMap;
  final int numErrors;

  T get value;
  Object get fields;

  Iterable<ValidationError> get allErrors => errorsMap.values.expand((e) => e);
  bool get hasErrors => numErrors > 0;
  bool get isValid => !hasErrors;

  Validated<T>? get validated => isValid ? Validated._(value) : null;

  ValidationError? toError({required String property}) {
    return ValidationError.fromNested(property, this);
  }
}

class Validator<T, V extends Validation<T, Object>> {
  final V Function(T) validate;

  const Validator(this.validate);
}
