import 'package:formgen/validate/serde_type.dart';
import 'package:formgen/validate/validate.dart';
import 'package:formgen/validate/validate_annotations.dart';

abstract class ValidateLength {
  int? get minLength;
  int? get maxLength;
}

class ValidateList<T> extends ValidateField<List<T>> implements ValidateLength {
  @override
  final int? minLength;
  @override
  final int? maxLength;
  final ValidateField<T>? each;

  @override
  ValidateFieldType get variantType => ValidateFieldType.list;

  @override
  final List<ValidationError> Function(List<T>)? customValidate;
  @override
  final String? customValidateName;

  const ValidateList({
    this.minLength,
    this.maxLength,
    this.each,
    this.customValidate,
    this.customValidateName,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      ValidateField.variantTypeString: variantType.toString(),
      'minLength': minLength,
      'maxLength': maxLength,
      'each': each?.toJson(),
    };
  }

  factory ValidateList.fromJson(Map<String, Object?> map) {
    return ValidateList(
      minLength: map['minLength'] as int?,
      maxLength: map['maxLength'] as int?,
      each: map['each'] == null
          ? null
          : (ValidateField.fromJson(map['each']! as Map<String, Object?>)
              as ValidateField<T>),
      customValidateName: map['customValidate'] as String?,
    );
  }

  static const fieldsSerde = {
    'minLength': SerdeType.int,
    'maxLength': SerdeType.int,
    'each': ValidateField.fieldsSerde,
    'customValidate': SerdeType.function,
  };
}

class ValidateSet<T> extends ValidateField<Set<T>> implements ValidateLength {
  @override
  final int? minLength;
  @override
  final int? maxLength;
  final ValidateField<T>? each;

  @override
  ValidateFieldType get variantType => ValidateFieldType.set;

  @override
  final List<ValidationError> Function(Set<T>)? customValidate;
  @override
  final String? customValidateName;

  const ValidateSet({
    this.minLength,
    this.maxLength,
    this.each,
    this.customValidate,
    this.customValidateName,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      ValidateField.variantTypeString: variantType.toString(),
      'minLength': minLength,
      'maxLength': maxLength,
      'each': each?.toJson(),
      'customValidate': customValidateName,
    };
  }

  factory ValidateSet.fromJson(Map<String, Object?> map) {
    return ValidateSet(
      minLength: map['minLength'] as int?,
      maxLength: map['maxLength'] as int?,
      each: map['each'] == null
          ? null
          : (ValidateField.fromJson(map['each']! as Map<String, Object?>)
              as ValidateField<T>),
      customValidateName: map['customValidate'] as String?,
    );
  }

  static const fieldsSerde = {
    'minLength': SerdeType.int,
    'maxLength': SerdeType.int,
    'each': ValidateField.fieldsSerde,
    'customValidate': SerdeType.function,
  };
}

class ValidateMap<K, V> extends ValidateField<Map<K, V>>
    implements ValidateLength {
  @override
  final int? minLength;
  @override
  final int? maxLength;
  final ValidateField<K>? eachKey;
  final ValidateField<V>? eachValue;

  @override
  ValidateFieldType get variantType => ValidateFieldType.map;

  @override
  final List<ValidationError> Function(Map<K, V>)? customValidate;
  @override
  final String? customValidateName;

  const ValidateMap({
    this.minLength,
    this.maxLength,
    this.eachKey,
    this.eachValue,
    this.customValidate,
    this.customValidateName,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      ValidateField.variantTypeString: variantType.toString(),
      'minLength': minLength,
      'maxLength': maxLength,
      'eachKey': eachKey?.toJson(),
      'eachValue': eachValue?.toJson(),
      'customValidate': customValidateName,
    };
  }

  factory ValidateMap.fromJson(Map<String, Object?> map) {
    return ValidateMap(
      minLength: map['minLength'] as int?,
      maxLength: map['maxLength'] as int?,
      eachKey: map['eachKey'] == null
          ? null
          : (ValidateField.fromJson(map['eachKey']! as Map<String, Object?>)
              as ValidateField<K>),
      eachValue: map['eachValue'] == null
          ? null
          : (ValidateField.fromJson(map['eachValue']! as Map<String, Object?>)
              as ValidateField<V>),
      customValidateName: map['customValidate'] as String?,
    );
  }

  static const fieldsSerde = {
    'minLength': SerdeType.int,
    'maxLength': SerdeType.int,
    'eachKey': ValidateField.fieldsSerde,
    'eachValue': ValidateField.fieldsSerde,
    'customValidate': SerdeType.function,
  };
}
