class SerdeType {
  final String _inner;
  const SerdeType._(this._inner);

  static const bool = SerdeType._('bool');
  static const int = SerdeType._('int');
  static const num = SerdeType._('num');
  static const function = SerdeType._('Function');
  static const str = SerdeType._('String');
  static const dynamic = SerdeType._('dynamic');
  static const duration = SerdeType._('Duration');
  const factory SerdeType.list(SerdeType generic) = SerdeTypeList._;
  const factory SerdeType.set(SerdeType generic) = SerdeTypeSet._;
  const factory SerdeType.map(
    SerdeType genericKey,
    SerdeType genericValue,
  ) = SerdeTypeMap._;
  const factory SerdeType.nested(Map<String, SerdeType> props) =
      SerdeTypeNested._;
  const factory SerdeType.union(
    String discriminator,
    Map<String, SerdeType> variants,
  ) = SerdeTypeUnion._;
  const factory SerdeType.unionType(
    Map<TypeMatcher, SerdeType> variants,
  ) = SerdeTypeUnionType._;
  const factory SerdeType.enumV(List values) = SerdeTypeEnum._;
  const factory SerdeType.late(SerdeType Function() func) = SerdeTypeLate._;

  T when<T>({
    required T Function() bool,
    required T Function() int,
    required T Function() num,
    required T Function() str,
    required T Function() duration,
    required T Function(SerdeTypeList) list,
    required T Function(SerdeTypeSet) set,
    required T Function(SerdeTypeMap) map,
    required T Function() function,
    required T Function(SerdeTypeNested) nested,
    required T Function(SerdeTypeUnion) union,
    required T Function(SerdeTypeUnionType) unionType,
    required T Function(SerdeTypeEnum) enumV,
    required T Function() dynamic,
  }) {
    switch (_inner) {
      case 'bool':
        return bool();
      case 'int':
        return int();
      case 'num':
        return num();
      case 'String':
        return str();
      case 'Duration':
        return duration();
      case 'Function':
        return function();
      case 'List':
        return list(this as SerdeTypeList);
      case 'Set':
        return set(this as SerdeTypeSet);
      case 'Map':
        return map(this as SerdeTypeMap);
      case 'Nested':
        return nested(this as SerdeTypeNested);
      case 'Union':
        return union(this as SerdeTypeUnion);
      case 'UnionType':
        return unionType(this as SerdeTypeUnionType);
      case 'enum':
        return enumV(this as SerdeTypeEnum);
      case 'dynamic':
        return dynamic();
      default:
        throw Error();
    }
  }
}

class SerdeTypeList extends SerdeType {
  final SerdeType generic;
  const SerdeTypeList._(this.generic) : super._('List');
}

class SerdeTypeSet extends SerdeType {
  final SerdeType generic;
  const SerdeTypeSet._(this.generic) : super._('Set');
}

class SerdeTypeMap extends SerdeType {
  final SerdeType genericKey;
  final SerdeType genericValue;
  const SerdeTypeMap._(this.genericKey, this.genericValue) : super._('Map');
}

class SerdeTypeNested extends SerdeType {
  final Map<String, SerdeType> props;
  const SerdeTypeNested._(this.props) : super._('Nested');
}

class SerdeTypeUnion extends SerdeType {
  final String discriminator;
  final Map<String, SerdeType> variants;
  const SerdeTypeUnion._(this.discriminator, this.variants) : super._('Union');
}

class SerdeTypeUnionType extends SerdeType {
  final Map<TypeMatcher, SerdeType> variants;
  const SerdeTypeUnionType._(this.variants) : super._('UnionType');
}

class TypeMatcher<T> {
  bool matches(Object? value) => value is T;
}

class SerdeTypeLate extends SerdeType {
  final SerdeType Function() func;
  const SerdeTypeLate._(this.func) : super._('Late');
}

class SerdeTypeEnum<T> extends SerdeType {
  final List<T> values;
  const SerdeTypeEnum._(this.values) : super._('enum');
}
