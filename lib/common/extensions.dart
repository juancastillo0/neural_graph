import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension GlobalPaintBoundsExt on BuildContext {
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      return renderObject!.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;

  MediaQueryData get mq => MediaQuery.of(this);

  Size get size => mq.size;
}

extension IndexedMap<T> on Iterable<T> {
  Iterable<V> mapIndex<V>(V Function(T, int) f) {
    int i = 0;
    return this.map((v) => f(v, i++));
  }

  Iterable<O> zip<O, V>(Iterable<V> it, O Function(T, V) f) sync* {
    final iterator = it.iterator;
    for (final v in this) {
      if (iterator.moveNext()) {
        yield f(v, iterator.current);
      } else {
        break;
      }
    }
  }
}

extension GetterSetterMap<K, V> on Map<K, V> {
  V? get(K key) {
    return this[key];
  }

  void set(K key, V value) {
    this[key] = value;
  }
}

T? parseEnum<T>(String rawString, List<T> enumValues) {
  for (final value in enumValues) {
    final str = value.toString();
    if (str == rawString || str.split('.')[1] == rawString) {
      return value;
    }
  }
  return null;
}

String toEnumString(Object enumValue) {
  return enumValue.toString().split('.')[1];
}

final _charsKey =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.split('');

extension GenerateString on Random {
  String generateKey([int length = 7]) {
    return Iterable<int>.generate(length).map((_) {
      final _index = (this.nextDouble() * _charsKey.length).floor();
      return _charsKey[_index];
    }).join();
  }
}

extension ValueListenableBuilderExtension<T> on ValueListenable<T> {
  Widget rebuild(Widget Function(T value) fn, {Key? key}) {
    return ValueListenableBuilder<T>(
      key: key,
      valueListenable: this,
      builder: (context, v, _) {
        return fn(v);
      },
    );
  }
}

extension ListenableBuilder on Listenable {
  Widget rebuild(Widget Function() fn) {
    return AnimatedBuilder(
      animation: this,
      builder: (context, _) {
        return fn();
      },
    );
  }
}

const dynamic importExtensions = null;
