import 'package:formgen/validate/serde_type.dart';
import 'package:formgen/validate/validate.dart';
import 'package:formgen/validate/validate_annotations.dart';

abstract class ValidateLength {
  int? get minLength;
  int? get maxLength;
}

class ValidateList<T> extends ValidateField<List<T>> implements ValidateLength {
  final int? minLength;
  final int? maxLength;
  final ValidateField<T>? each;

  ValidateFieldType get variantType => ValidateFieldType.list;

  final List<ValidationError> Function(List<T>)? customValidate;
  final String? customValidateName;

  const ValidateList({
    this.minLength,
    this.maxLength,
    this.each,
    this.customValidate,
    this.customValidateName,
  });

  Map<String, dynamic> toJson() {
    return {
      ValidateField.variantTypeString: variantType.toString(),
      'minLength': minLength,
      'maxLength': maxLength,
      'each': each?.toJson(),
    };
  }

  factory ValidateList.fromJson(Map<String, dynamic> map) {
    return ValidateList(
      minLength: map['minLength'],
      maxLength: map['maxLength'],
      each: map['each'] == null
          ? null
          : (ValidateField.fromJson(map['each']) as ValidateField<T>),
      customValidateName: map['customValidate'],
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
  final int? minLength;
  final int? maxLength;
  final ValidateField<T>? each;

  ValidateFieldType get variantType => ValidateFieldType.set;

  final List<ValidationError> Function(Set<T>)? customValidate;
  final String? customValidateName;

  const ValidateSet({
    this.minLength,
    this.maxLength,
    this.each,
    this.customValidate,
    this.customValidateName,
  });

  Map<String, dynamic> toJson() {
    return {
      ValidateField.variantTypeString: variantType.toString(),
      'minLength': minLength,
      'maxLength': maxLength,
      'each': each?.toJson(),
      'customValidate': customValidateName,
    };
  }

  factory ValidateSet.fromJson(Map<String, dynamic> map) {
    return ValidateSet(
      minLength: map['minLength'],
      maxLength: map['maxLength'],
      each: map['each'] == null
          ? null
          : (ValidateField.fromJson(map['each']) as ValidateField<T>),
      customValidateName: map['customValidate'],
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
  final int? minLength;
  final int? maxLength;
  final ValidateField<K>? eachKey;
  final ValidateField<V>? eachValue;

  ValidateFieldType get variantType => ValidateFieldType.map;

  final List<ValidationError> Function(Map<K, V>)? customValidate;
  final String? customValidateName;

  const ValidateMap({
    this.minLength,
    this.maxLength,
    this.eachKey,
    this.eachValue,
    this.customValidate,
    this.customValidateName,
  });

  Map<String, dynamic> toJson() {
    return {
      ValidateField.variantTypeString: variantType.toString(),
      'minLength': minLength,
      'maxLength': maxLength,
      'eachKey': eachKey?.toJson(),
      'eachValue': eachValue?.toJson(),
      'customValidate': customValidateName,
    };
  }

  factory ValidateMap.fromJson(Map<String, dynamic> map) {
    return ValidateMap(
      minLength: map['minLength'],
      maxLength: map['maxLength'],
      eachKey: map['eachKey'] == null
          ? null
          : (ValidateField.fromJson(map['eachKey']) as ValidateField<K>),
      eachValue: map['eachValue'] == null
          ? null
          : (ValidateField.fromJson(map['eachValue']) as ValidateField<V>),
      customValidateName: map['customValidate'],
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
