import 'package:formgen/formgen.dart';

part 'model.g.dart';

// global config from build.yaml
// more annotations
// custom validator ergonomics, for field and for class
// nested validation execution and result

List<ValidationError> _customValidateStr(String value) {
  return [];
}

@Validate(nullableErrorLists: true, customValidate: FormTest._customValidate)
class FormTest {
  static List<ValidationError> _customValidate(Object? value) {
    return [];
  }

  @ValidateString(
    minLength: 15,
    maxLength: 50,
    matches: r'^[a-zA-Z]+$',
    customValidate: _customValidateStr,
  )
  final String longStr;

  @ValidateString(maxLength: 20, contains: '@')
  final String shortStr;

  @ValidateNum(isInt: true, min: 0, customValidate: _customValidateNum)
  final num positiveInt;

  static List<ValidationError> _customValidateNum(num value) {
    return [];
  }

  @ValidationFunction()
  static List<ValidationError> _customValidate2(FormTest value) {
    return [
      if (value.optionalDecimal == null && value.identifier == null)
        ValidationError(
          errorCode: 'CustomError.not',
          message: 'CustomError message',
          property: 'identifier',
          value: value,
        )
    ];
  }

  @ValidationFunction()
  List<ValidationError> _customValidate3() {
    return _customValidate2(this);
  }

  @ValidateNum(
    min: 0,
    max: 1,
    comp: ValidateComparison<num>(
      less: CompVal(0),
      moreEq: CompVal.list([CompVal.ref('positiveInt')]),
    ),
  )
  final double? optionalDecimal;

  @ValidateList(minLength: 1, each: ValidateString(isDate: true, maxLength: 3))
  final List<String> nonEmptyList;

  @ValidateString(isUUID: UUIDVersion.v4)
  final String? identifier;

  final NestedField? nested;

  const FormTest({
    required this.longStr,
    required this.shortStr,
    required this.positiveInt,
    required this.optionalDecimal,
    required this.nonEmptyList,
    required this.identifier,
    this.nested,
  });
}

@Validate()
class NestedField {
  @ValidateString(isTime: true)
  final String timeStr;

  @ValidateDate(min: '2021-01-01')
  final DateTime dateWith2021Min;

  @ValidateDate(max: 'now')
  final DateTime? optionalDateWithNowMax;

  NestedField({
    required this.timeStr,
    required this.dateWith2021Min,
    required this.optionalDateWithNowMax,
  });
}
