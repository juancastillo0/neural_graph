import 'dart:convert';

import 'package:formgen/formgen.dart';
import 'package:formgen/validate/serde_type.dart';

abstract class CompVal<T extends Comparable<T>> {
  const CompVal._();

  static const fieldsSerde = SerdeType.late(_makeFieldsSerde);
  static SerdeType _makeFieldsSerde() {
    return SerdeType.union(
      'variantType',
      {
        'ref': SerdeType.nested(CompValueRef.fieldsSerde),
        'single': SerdeType.nested(CompValueSingle.fieldsSerde),
        'list': SerdeType.nested(CompValueList.fieldsSerde),
      },
    );
  }

  const factory CompVal(T value) = CompValueSingle<T>;
  const factory CompVal.ref(
    String ref,
  ) = CompValueRef<T>;
  const factory CompVal.single(
    T value,
  ) = CompValueSingle<T>;
  const factory CompVal.list(
    List<CompVal<T>> values,
  ) = CompValueList<T>;

  _T when<_T>({
    required _T Function(String ref) ref,
    required _T Function(T value) single,
    required _T Function(List<CompVal<T>> values) list,
  }) {
    final v = this;
    if (v is CompValueRef<T>) {
      return ref(v.ref);
    } else if (v is CompValueSingle<T>) {
      return single(v.value);
    } else if (v is CompValueList<T>) {
      return list(v.values);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(String ref)? ref,
    _T Function(T value)? single,
    _T Function(List<CompVal<T>> values)? list,
  }) {
    final v = this;
    if (v is CompValueRef<T>) {
      return ref != null ? ref(v.ref) : orElse.call();
    } else if (v is CompValueSingle<T>) {
      return single != null ? single(v.value) : orElse.call();
    } else if (v is CompValueList<T>) {
      return list != null ? list(v.values) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(CompValueRef<T> value) ref,
    required _T Function(CompValueSingle<T> value) single,
    required _T Function(CompValueList<T> value) list,
  }) {
    final v = this;
    if (v is CompValueRef<T>) {
      return ref(v);
    } else if (v is CompValueSingle<T>) {
      return single(v);
    } else if (v is CompValueList<T>) {
      return list(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(CompValueRef<T> value)? ref,
    _T Function(CompValueSingle<T> value)? single,
    _T Function(CompValueList<T> value)? list,
  }) {
    final v = this;
    if (v is CompValueRef<T>) {
      return ref != null ? ref(v) : orElse.call();
    } else if (v is CompValueSingle<T>) {
      return single != null ? single(v) : orElse.call();
    } else if (v is CompValueList<T>) {
      return list != null ? list(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isRef => this is CompValueRef;
  bool get isSingle => this is CompValueSingle;
  bool get isList => this is CompValueList;

  TypeCompVal get variantType;

  static CompVal<T> fromJson<T extends Comparable<T>>(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is CompVal<T>) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['variantType'] as String) {
      case 'ref':
        return CompValueRef.fromJson<T>(map);
      case 'single':
        return CompValueSingle.fromJson<T>(map);
      case 'list':
        return CompValueList.fromJson<T>(map);
      default:
        throw Exception(
            'Invalid discriminator for CompVal<T extends Comparable<T>>.fromJson '
            '${map["variantType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class TypeCompVal {
  final String _inner;

  const TypeCompVal._(this._inner);

  static const ref = TypeCompVal._('ref');
  static const single = TypeCompVal._('single');
  static const list = TypeCompVal._('list');

  static const values = [
    TypeCompVal.ref,
    TypeCompVal.single,
    TypeCompVal.list,
  ];

  static TypeCompVal fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      if (json.toString() == v._inner) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other is TypeCompVal &&
        other.runtimeType == runtimeType &&
        other._inner == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isRef => this == TypeCompVal.ref;
  bool get isSingle => this == TypeCompVal.single;
  bool get isList => this == TypeCompVal.list;

  _T when<_T>({
    required _T Function() ref,
    required _T Function() single,
    required _T Function() list,
  }) {
    switch (this._inner) {
      case 'ref':
        return ref();
      case 'single':
        return single();
      case 'list':
        return list();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? ref,
    _T Function()? single,
    _T Function()? list,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'ref':
        c = ref;
        break;
      case 'single':
        c = single;
        break;
      case 'list':
        c = list;
        break;
    }
    return (c ?? orElse).call();
  }
}

class CompValueRef<T extends Comparable<T>> extends CompVal<T> {
  final String ref;

  const CompValueRef(
    this.ref,
  ) : super._();

  @override
  final TypeCompVal variantType = TypeCompVal.ref;

  static CompValueRef<T> fromJson<T extends Comparable<T>>(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is CompValueRef<T>) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return CompValueRef<T>(
      map['ref'] as String,
    );
  }

  @override
  String toString() {
    return '$ref';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'variantType': 'ref',
      'ref': ref,
    };
  }

  static const fieldsSerde = {
    'ref': SerdeType.str,
  };
}

class CompValueSingle<T extends Comparable<T>> extends CompVal<T> {
  final T value;

  const CompValueSingle(
    this.value,
  ) : super._();

  @override
  final TypeCompVal variantType = TypeCompVal.single;

  @override
  String toString() {
    return '$value';
  }

  static CompValueSingle<T> fromJson<T extends Comparable<T>>(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is CompValueSingle<T>) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return CompValueSingle<T>(
      map['value'] as T,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'variantType': 'single',
      'value': value,
    };
  }

  static const fieldsSerde = {
    'value': SerdeType.dynamic,
  };
}

class CompValueList<T extends Comparable<T>> extends CompVal<T> {
  final List<CompVal<T>> values;

  const CompValueList(
    this.values,
  ) : super._();

  @override
  final TypeCompVal variantType = TypeCompVal.list;

  @override
  String toString() {
    return '[${values.join(' , ')}]';
  }

  static CompValueList<T> fromJson<T extends Comparable<T>>(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is CompValueList<T>) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return CompValueList<T>(
      (map['values'] as List)
          .map((e) => CompVal.fromJson<T>(e))
          .toList()
          .cast(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'variantType': 'list',
      'values': values.map((e) => e.toJson()).toList(),
    };
  }

  static const fieldsSerde = {
    'values': SerdeType.list(CompVal.fieldsSerde),
  };
}
