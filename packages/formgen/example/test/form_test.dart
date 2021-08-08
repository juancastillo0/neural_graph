import 'package:formgen_example/model.dart';
import 'package:test/test.dart';

void main() {
  test('validate FormTest', () {
    final form = FormTest(
      longStr: 'long Str',
      shortStr: 'shortStr',
      positiveInt: 2.4,
      optionalDecimal: 3,
      nonEmptyList: [],
      identifier: 'identifier',
    );

    final errors = validateFormTest(form);
    expect(errors.numErrors, errors.allErrors.length);
    expect(errors.hasErrors, true);
    expect(errors.fields.nonEmptyList, isNotNull);

    final errorsMap = errors.errorsMap;

    expect(errorsMap.isNotEmpty, true);
    expect(errorsMap['longStr']?.length, 2);
    expect(errorsMap['shortStr']?.length, 1);
    expect(errorsMap['positiveInt']?.length, 1);
    expect(errorsMap['nonEmptyList']?.length, 1);
    expect(errorsMap['optionalDecimal']?.length, 1);
  });
}
