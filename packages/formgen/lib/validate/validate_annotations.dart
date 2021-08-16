import 'package:formgen/validate/serde_type.dart';
import 'package:formgen/validate/validate.dart';
import 'package:formgen/validate/validate_collections.dart';
import 'package:formgen/validate/validate_string.dart';
import 'models/comp_val.dart';

export 'models/comp_val.dart';
export 'validate_collections.dart';
export 'validate_string.dart';

class Validate<T> implements ValidateCustom<T> {
  final bool nullableErrorLists;
  final bool constErrors;
  final bool enumFields;

  @override
  final List<ValidationError> Function(T)? customValidate;
  @override
  final String? customValidateName;

  const Validate({
    bool? nullableErrorLists,
    bool? constErrors,
    bool? enumFields,
    this.customValidate,
    this.customValidateName,
  })  : nullableErrorLists = nullableErrorLists ?? false,
        constErrors = constErrors ?? false,
        enumFields = enumFields ?? true;

  static const fieldsSerde = {
    'nullableErrorLists': SerdeType.bool,
    'constErrors': SerdeType.bool,
    'enumFields': SerdeType.bool,
    'customValidate': SerdeType.function,
  };

  Map<String, Object?> toJson() {
    return {
      'nullableErrorLists': nullableErrorLists,
      'constErrors': constErrors,
      'enumFields': enumFields,
      'customValidate': customValidateName,
    };
  }

  factory Validate.fromJson(Map<String, Object?> map) {
    return Validate(
      nullableErrorLists: map['nullableErrorLists'] as bool?,
      constErrors: map['constErrors'] as bool?,
      enumFields: map['enumFields'] as bool?,
      customValidateName: map['customValidate'] as String?,
    );
  }
}

class ValidationFunction {
  const ValidationFunction();
}

enum ValidateFieldType {
  num,
  string,
  date,
  duration,
  list,
  map,
  set,
}

ValidateFieldType parseValidateFieldType(String raw) {
  for (final v in ValidateFieldType.values) {
    final str = v.toString();
    if (str == raw || str.split('.')[1] == raw) {
      return v;
    }
  }
  throw Error();
}

abstract class ValidateCustom<T> {
  List<ValidationError> Function(T)? get customValidate;
  String? get customValidateName;
}

abstract class ValidateComparable<T extends Comparable<T>> {
  ValidateComparison<T>? get comp;
}

class ValidateComparison<T extends Comparable<T>> {
  final bool useCompareTo;
  final CompVal<T>? more;
  final CompVal<T>? less;
  final CompVal<T>? moreEq;
  final CompVal<T>? lessEq;

  const ValidateComparison({
    this.more,
    this.less,
    this.moreEq,
    this.lessEq,
    bool? useCompareTo,
  }) : useCompareTo = useCompareTo ?? true;

  static const fieldsSerde = SerdeType.nested({
    'more': CompVal.fieldsSerde,
    'less': CompVal.fieldsSerde,
    'moreEq': CompVal.fieldsSerde,
    'lessEq': CompVal.fieldsSerde,
    'useCompareTo': SerdeType.bool,
  });

  Map<String, Object?> toJson() {
    return {
      'more': more?.toJson(),
      'less': less?.toJson(),
      'moreEq': moreEq?.toJson(),
      'lessEq': lessEq?.toJson(),
      'useCompareTo': useCompareTo,
    };
  }

  factory ValidateComparison.fromJson(Map<String, Object?> map) {
    return ValidateComparison<T>(
      more: map['more'] == null ? null : CompVal.fromJson<T>(map['more']),
      less: map['less'] == null ? null : CompVal.fromJson<T>(map['less']),
      moreEq: map['moreEq'] == null ? null : CompVal.fromJson<T>(map['moreEq']),
      lessEq: map['lessEq'] == null ? null : CompVal.fromJson<T>(map['lessEq']),
      useCompareTo: map['useCompareTo'] as bool?,
    );
  }
}

// abstract class CompVal<T extends Comparable> {
//   const CompVal._();

//   const factory CompVal(T value) = CompValSingle;
//   const factory CompVal.ref(String ref) = CompValRef;
//   const factory CompVal.single(T value) = CompValSingle;
//   const factory CompVal.many(List<CompVal<T>> value) = CompValMany;

//   static const fieldsSerde = SerdeType.late(_makeFieldsSerde);
//   static SerdeType _makeFieldsSerde() {
//     return SerdeType.union(
//       'discriminator',
//       {},
//     );
//   }
// }

// class CompValRef<T extends Comparable> extends CompVal<T> {
//   final String ref;

//   const CompValRef(this.ref) : super._();
// }

// class CompValSingle<T extends Comparable> extends CompVal<T> {
//   final T value;

//   const CompValSingle(this.value) : super._();
// }

// class CompValMany<T extends Comparable> extends CompVal<T> {
//   final List<CompVal<T>> values;

//   const CompValMany(this.values) : super._();
// }

abstract class ValidateField<T> implements ValidateCustom<T> {
  const ValidateField();

  Map<String, Object?> toJson();

  ValidateFieldType get variantType;

  static const variantTypeString = 'variantType';

  static const fieldsSerde = SerdeType.late(_makeFieldsSerde);
  static SerdeType _makeFieldsSerde() {
    return const SerdeType.union(
      ValidateField.variantTypeString,
      {
        'num': SerdeType.nested(ValidateNum.fieldsSerde),
        'string': SerdeType.nested(ValidateString.fieldsSerde),
        'date': SerdeType.nested(ValidateDate.fieldsSerde),
        'duration': SerdeType.nested(ValidateDuration.fieldsSerde),
        'list': SerdeType.nested(ValidateList.fieldsSerde),
        'set': SerdeType.nested(ValidateSet.fieldsSerde),
        'map': SerdeType.nested(ValidateMap.fieldsSerde),
      },
    );
  }

  _T when<_T>({
    required _T Function(ValidateString) string,
    required _T Function(ValidateNum) num,
    required _T Function(ValidateDate) date,
    required _T Function(ValidateDuration) duration,
    required _T Function(ValidateList) list,
    required _T Function(ValidateMap) map,
    required _T Function(ValidateSet) set,
  }) {
    switch (variantType) {
      case ValidateFieldType.string:
        return string(this as ValidateString);
      case ValidateFieldType.num:
        return num(this as ValidateNum);
      case ValidateFieldType.date:
        return date(this as ValidateDate);
      case ValidateFieldType.duration:
        return duration(this as ValidateDuration);
      case ValidateFieldType.list:
        return list(this as ValidateList);
      case ValidateFieldType.map:
        return map(this as ValidateMap);
      case ValidateFieldType.set:
        return set(this as ValidateSet);
    }
  }

  static ValidateField fromJson(Map<String, Object?> map) {
    final type = parseValidateFieldType(
      (map[ValidateField.variantTypeString] ??
          map['runtimeType'] ??
          map['type'])! as String,
    );
    switch (type) {
      case ValidateFieldType.string:
        return ValidateString.fromJson(map);
      case ValidateFieldType.num:
        return ValidateNum.fromJson(map);
      case ValidateFieldType.date:
        return ValidateDate.fromJson(map);
      case ValidateFieldType.duration:
        return ValidateDuration.fromJson(map);
      case ValidateFieldType.list:
        return ValidateList.fromJson(map);
      case ValidateFieldType.map:
        return ValidateMap.fromJson(map);
      case ValidateFieldType.set:
        return ValidateSet.fromJson(map);
    }
  }
}

class ValidateNum extends ValidateField<num>
    implements ValidateComparable<num> {
  final List<num>? isIn; // enum
  final num? min;
  final num? max;
  final bool? isInt;
  final num? isDivisibleBy;
  @override
  final ValidateComparison<num>? comp;

  @override
  ValidateFieldType get variantType => ValidateFieldType.num;

  @override
  final List<ValidationError> Function(num)? customValidate;
  @override
  final String? customValidateName;

  const ValidateNum({
    this.isIn,
    this.min,
    this.max,
    this.isInt,
    this.isDivisibleBy,
    this.customValidate,
    this.customValidateName,
    this.comp,
  });

  static const fieldsSerde = {
    'min': SerdeType.num,
    'max': SerdeType.num,
    'isInt': SerdeType.bool,
    'isIn': SerdeType.list(SerdeType.num),
    'isDivisibleBy': SerdeType.num,
    'customValidate': SerdeType.function,
    'comp': ValidateComparison.fieldsSerde,
  };

  @override
  Map<String, Object?> toJson() {
    return {
      ValidateField.variantTypeString: variantType.toString(),
      'isIn': isIn,
      'min': min,
      'max': max,
      'isInt': isInt,
      'isDivisibleBy': isDivisibleBy,
      'customValidate': customValidateName,
      'comp': comp?.toJson(),
    };
  }

  factory ValidateNum.fromJson(Map<String, Object?> map) {
    return ValidateNum(
      isIn: map['isIn'] == null ? null : List<num>.from(map['isIn']! as List),
      min: map['min'] as int?,
      max: map['max'] as int?,
      isInt: map['isInt'] as bool?,
      isDivisibleBy: map['isDivisibleBy'] as int?,
      customValidateName: map['customValidate'] as String?,
      comp: map['comp'] == null
          ? null
          : ValidateComparison.fromJson(map['comp']! as Map<String, Object?>),
    );
  }
}

class ValidateDuration extends ValidateField<Duration>
    implements ValidateComparable<Duration> {
  final Duration? min;
  final Duration? max;

  @override
  ValidateFieldType get variantType => ValidateFieldType.duration;

  @override
  final List<ValidationError> Function(Duration)? customValidate;
  @override
  final String? customValidateName;

  @override
  final ValidateComparison<Duration>? comp;

  const ValidateDuration({
    this.min,
    this.max,
    this.customValidate,
    this.customValidateName,
    this.comp,
  });

  static const fieldsSerde = {
    'min': SerdeType.duration,
    'max': SerdeType.duration,
    'customValidate': SerdeType.function,
    'comp': ValidateComparison.fieldsSerde,
  };

  @override
  Map<String, Object?> toJson() {
    return {
      ValidateField.variantTypeString: variantType.toString(),
      'min': min?.inMicroseconds,
      'max': max?.inMicroseconds,
      'customValidate': customValidateName,
      'comp': comp?.toJson(),
    };
  }

  factory ValidateDuration.fromJson(Map<String, Object?> map) {
    return ValidateDuration(
      min: map['min'] == null
          ? null
          : Duration(microseconds: map['min']! as int),
      max: map['max'] == null
          ? null
          : Duration(microseconds: map['max']! as int),
      customValidateName: map['customValidate'] as String?,
      comp: map['comp'] == null
          ? null
          : ValidateComparison.fromJson(map['comp']! as Map<String, Object?>),
    );
  }
}

class ValidateDate extends ValidateField<DateTime>
    implements ValidateComparable<String> {
  final String? min;
  final String? max;

  @override
  ValidateFieldType get variantType => ValidateFieldType.date;

  @override
  final List<ValidationError> Function(DateTime)? customValidate;
  @override
  final String? customValidateName;

  @override
  final ValidateComparison<String>? comp;

  const ValidateDate({
    this.min,
    this.max,
    this.customValidate,
    this.customValidateName,
    this.comp,
  });

  static const fieldsSerde = {
    'min': SerdeType.str,
    'max': SerdeType.str,
    'customValidate': SerdeType.function,
    'comp': ValidateComparison.fieldsSerde,
  };

  @override
  Map<String, Object?> toJson() {
    return {
      ValidateField.variantTypeString: variantType.toString(),
      'min': min,
      'max': max,
      'customValidate': customValidateName,
      'comp': comp?.toJson(),
    };
  }

  factory ValidateDate.fromJson(Map<String, Object?> map) {
    return ValidateDate(
      min: map['min'] as String?,
      max: map['max'] as String?,
      customValidateName: map['customValidate'] as String?,
      comp: map['comp'] == null
          ? null
          : ValidateComparison.fromJson(map['comp']! as Map<String, Object?>),
    );
  }
}
