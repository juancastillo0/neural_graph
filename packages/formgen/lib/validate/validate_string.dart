import 'package:formgen/validate/serde_type.dart';
import 'package:formgen/validate/validate.dart';
import 'package:formgen/validate/validate_annotations.dart';

enum IPVersion {
  v4,
  v6,
}

enum UUIDVersion {
  v3,
  v4,
  v5,
  all,
}

enum ISBNVersion { v10, v13 }

T? parseEnum<T>(String? raw, List<T> enumValues) {
  if (raw == null) {
    return null;
  }
  for (final value in enumValues) {
    final str = value.toString();
    if (raw == str || raw == str.split('.')[1]) {
      return value;
    }
  }
  throw Error();
}

String? toEnumString(Object? value) {
  return value == null ? null : value.toString().split('.')[1];
}

class ValidateString extends ValidateField<String> implements ValidateLength {
  final List<String>? isIn; // enum

  final int? minLength;
  final int? maxLength;
  final bool? isPhone;
  final bool? isEmail;
  final bool? isDate;
  final bool? isTime;
  final bool? isBool;
  final bool? isNum;
  final bool? isUrl;
  final UUIDVersion? isUUID;
  final bool? isCurrency;
  final bool? isJSON;

  final String? matches;
  final String? contains;
  final bool? isAlpha;
  final bool? isAlphanumeric;

  // isVariableWidth, isHalfWidth, isFullWidth, isSurrogatePair, isPostalCode, isMultibyte,
  final bool? isAscii;
  final bool? isBase64;
  final bool? isCreditCard;
  final bool? isFQDN;
  final bool? isHexadecimal;
  final bool? isHexColor;
  final bool? isInt;
  final bool? isFloat;
  final ISBNVersion? isISBN;
  final IPVersion? isIP;

  final int? isDivisibleBy;
  final int? surrogatePairsLengthMin;
  final int? surrogatePairsLengthMax;

  final bool? isLowercase;
  final bool? isUppercase;

  final ValidateFieldType variantType = ValidateFieldType.string;

  final List<ValidationError> Function(String)? customValidate;
  final String? customValidateName;

  const ValidateString({
    this.isIn,
    this.maxLength,
    this.minLength,
    this.isPhone,
    this.isEmail,
    this.isDate,
    this.isTime,
    this.isBool,
    this.isNum,
    this.isUrl,
    this.isUUID,
    this.isCurrency,
    this.isJSON,
    this.matches,
    this.contains,
    this.isAlpha,
    this.isAlphanumeric,
    this.isLowercase,
    this.isUppercase,
    //
    this.isAscii,
    this.isBase64,
    this.isCreditCard,
    this.isDivisibleBy,
    this.surrogatePairsLengthMin,
    this.surrogatePairsLengthMax,
    this.isFQDN,
    this.isHexadecimal,
    this.isHexColor,
    this.isInt,
    this.isFloat,
    this.isISBN,
    this.isIP,
    //
    this.customValidate,
    this.customValidateName,
  });

  Map<String, dynamic> toJson() {
    return {
      ValidateField.variantTypeString: variantType.toString(),
      'isIn': isIn,
      'maxLength': maxLength,
      'minLength': minLength,
      'isPhone': isPhone,
      'isEmail': isEmail,
      'isDate': isDate,
      'isTime': isTime,
      'isBool': isBool,
      'isNum': isNum,
      'isUrl': isUrl,
      'isUUID': toEnumString(isUUID),
      'isCurrency': isCurrency,
      'isJSON': isJSON,
      'matches': matches,
      'contains': contains,
      'isAlpha': isAlpha,
      'isAlphanumeric': isAlphanumeric,
      'isLowercase': isLowercase,
      'isUppercase': isUppercase,
      'customValidate': customValidateName,
      'isAscii': isAscii,
      'isBase64': isBase64,
      'isCreditCard': isCreditCard,
      'isFQDN': isFQDN,
      'isHexadecimal': isHexadecimal,
      'isHexColor': isHexColor,
      'isDivisibleBy': isDivisibleBy,
      'surrogatePairsLengthMin': surrogatePairsLengthMin,
      'surrogatePairsLengthMax': surrogatePairsLengthMax,
      'isInt': isInt,
      'isFloat': isFloat,
      'isISBN': toEnumString(isISBN),
      'isIP': toEnumString(isIP),
    }..removeWhere((key, value) => value == null);
  }

  factory ValidateString.fromJson(Map<String, dynamic> map) {
    return ValidateString(
      isIn: map['isIn'] == null ? null : List<String>.from(map['isIn']),
      maxLength: map['maxLength'],
      minLength: map['minLength'],
      isPhone: map['isPhone'],
      isEmail: map['isEmail'],
      isDate: map['isDate'],
      isTime: map['isTime'],
      isBool: map['isBool'],
      isNum: map['isNum'],
      isUrl: map['isUrl'],
      isUUID: map['isUUID'] is UUIDVersion
          ? map['isUUID']
          : parseEnum(map['isUUID'] as String?, UUIDVersion.values),
      isCurrency: map['isCurrency'],
      isJSON: map['isJSON'],
      matches: map['matches'],
      contains: map['contains'],
      isAlpha: map['isAlpha'],
      isAlphanumeric: map['isAlphanumeric'],
      isLowercase: map['isLowercase'],
      isUppercase: map['isUppercase'],
      customValidateName: map['customValidate'],
      isAscii: map['isAscii'],
      isBase64: map['isBase64'],
      isCreditCard: map['isCreditCard'],
      isFQDN: map['isFQDN'],
      isHexadecimal: map['isHexadecimal'],
      isHexColor: map['isHexColor'],
      isDivisibleBy: map['isDivisibleBy'],
      surrogatePairsLengthMin: map['surrogatePairsLengthMin'],
      surrogatePairsLengthMax: map['surrogatePairsLengthMax'],
      isInt: map['isInt'],
      isFloat: map['isFloat'],
      isISBN: map['isISBN'] is ISBNVersion
          ? map['isISBN']
          : parseEnum(map['isISBN'] as String?, ISBNVersion.values),
      isIP: map['isIP'] is IPVersion
          ? map['isIP']
          : parseEnum(map['isIP'] as String?, IPVersion.values),
    );
  }

  static const fieldsSerde = {
    'isIn': SerdeType.list(SerdeType.str),
    'maxLength': SerdeType.int,
    'minLength': SerdeType.int,
    'isPhone': SerdeType.bool,
    'isEmail': SerdeType.bool,
    'isDate': SerdeType.bool,
    'isTime': SerdeType.bool,
    'isBool': SerdeType.bool,
    'isNum': SerdeType.bool,
    'isUrl': SerdeType.bool,
    'isUUID': SerdeType.enumV(UUIDVersion.values),
    'isCurrency': SerdeType.bool,
    'isJSON': SerdeType.bool,
    'matches': SerdeType.str,
    'contains': SerdeType.str,
    'isAlpha': SerdeType.bool,
    'isAlphanumeric': SerdeType.bool,
    'isLowercase': SerdeType.bool,
    'isUppercase': SerdeType.bool,
    'customValidate': SerdeType.function,
    'isAscii': SerdeType.bool,
    'isBase64': SerdeType.bool,
    'isCreditCard': SerdeType.bool,
    'isFQDN': SerdeType.bool,
    'isHexadecimal': SerdeType.bool,
    'isHexColor': SerdeType.bool,
    'isDivisibleBy': SerdeType.int,
    'surrogatePairsLengthMin': SerdeType.int,
    'surrogatePairsLengthMax': SerdeType.int,
    'isInt': SerdeType.bool,
    'isFloat': SerdeType.bool,
    'isISBN': SerdeType.enumV(ISBNVersion.values),
    'isIP': SerdeType.enumV(IPVersion.values),
  };
}
