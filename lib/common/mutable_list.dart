import 'dart:math';
import 'package:flutter/foundation.dart';

@immutable
abstract class Event {}

typedef TypeS<T, E> = T Function(E);

enum ListEventEnum { change, insert, remove, many }

@immutable
abstract class ListEvent<E> implements Event {
  const ListEvent._();

  const factory ListEvent.change(int index, {E? oldValue, E? newValue}) =
      ChangeListEvent._;
  const factory ListEvent.insert(int index, E value) = InsertListEvent._;
  const factory ListEvent.remove(int index, E value) = RemoveListEvent._;
  const factory ListEvent.many(List<ListEvent<E>> events) = ManyListEvent._;

  ListEventEnum get typeId {
    final ListEvent<E> v = this;
    if (v is ChangeListEvent<E>) {
      return ListEventEnum.change;
    } else if (v is InsertListEvent<E>) {
      return ListEventEnum.insert;
    } else if (v is RemoveListEvent<E>) {
      return ListEventEnum.remove;
    } else if (v is ManyListEvent<E>) {
      return ListEventEnum.many;
    }
    throw Error();
  }

  bool isType(ListEventEnum type) => type == typeId;

  T when<T>({
    T Function(ChangeListEvent<E>)? change,
    T Function(InsertListEvent<E>)? insert,
    T Function(RemoveListEvent<E>)? remove,
    T Function(ManyListEvent<E>)? many,
  }) {
    final callback =
        [change, insert, remove, many] as List<T Function(ListEvent<E>)?>;
    return callback[typeId.index]!(this);
  }

  ListEvent<E> revert();
}

class ChangeListEvent<E> extends ListEvent<E> {
  const ChangeListEvent._(this.index, {this.oldValue, this.newValue})
      : super._();
  final int index;
  final E? oldValue;
  final E? newValue;

  @override
  ListEvent<E> revert() {
    return ListEvent.change(index, newValue: oldValue, oldValue: newValue);
  }
}

class InsertListEvent<E> extends ListEvent<E> {
  const InsertListEvent._(this.index, this.value) : super._();
  final int index;
  final E value;

  @override
  ListEvent<E> revert() {
    return ListEvent.remove(index, value);
  }
}

class RemoveListEvent<E> extends ListEvent<E> {
  const RemoveListEvent._(this.index, this.value) : super._();
  final int index;
  final E value;

  @override
  ListEvent<E> revert() {
    return ListEvent.insert(index, value);
  }
}

class ManyListEvent<E> extends ListEvent<E> {
  const ManyListEvent._(this.events) : super._();
  final List<ListEvent<E>> events;

  @override
  ListEvent<E> revert() {
    return ListEvent.many(
      events.map((e) => e.revert()).toList().reversed.toList(),
    );
  }
}

abstract class EventConsumer<V extends Event> {
  EventConsumer({
    int? maxHistoryLength,
  }) : history = EventHistory(maxHistoryLength: maxHistoryLength);

  final EventHistory<V> history;

  void apply(V e) {
    history.add(e);
    _consume(e);
  }

  @protected
  void _consume(V e);
}

class EventHistory<V extends Event> {
  EventHistory({
    int? maxHistoryLength,
  }) : maxHistoryLength = maxHistoryLength ?? 25;

  final int maxHistoryLength;
  final List<V> history = const [];
  int _index = 0;

  void revert() {
    if (_index == 0) {
    } else {
      _index -= 1;
    }
  }

  void forward() {
    if (_index == history.length - 1) {
    } else {
      _index += 1;
    }
  }

  void add(V event) {
    history.add(event);
  }

  @override
  bool operator ==(Object other) {
    if (other is EventHistory) {
      return other._index == _index && other.history == history;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => Object.hash(_index, history);
}

class MutableList<E> extends EventConsumer<ListEvent<E?>> implements List<E?> {
  MutableList(
    List<E> inner, {
    int? maxHistoryLength,
  })  : _inner = inner,
        super(maxHistoryLength: maxHistoryLength);

  final List<E?> _inner;

  // @override
  // bool operator ==(Object other) {
  //   if (other is MutableList) {
  //     return other.history == history && other._inner == _inner;
  //   }
  //   return false;
  // }

  // @override
  // int get hashCode => super.hashCode;

  @override
  void _consume(ListEvent<E?> e) {
    e.when(
      change: (c) {
        _inner[c.index] = c.newValue;
      },
      insert: (c) {
        _inner.insert(c.index, c.value);
      },
      remove: (c) {
        _inner.removeAt(c.index);
      },
      many: (c) {
        c.events.forEach(_consume);
      },
    );
  }

  @override
  set length(int newLength) {
    _inner.length = newLength;
  }

  @override
  E? operator [](int index) {
    return _inner[index];
  }

  //
  // INSERT SINGLE

  @override
  void add(E? value) {
    apply(ListEvent.insert(_inner.length, value));
  }

  @override
  void insert(int index, E? element) {
    apply(ListEvent.insert(index, element));
  }

  //
  // INSERT MANY

  @override
  MutableList<E?> operator +(List<E?> other) {
    addAll(other);
    return MutableList(_inner + other);
  }

  @override
  void addAll(Iterable<E?> iterable) {
    int offset = length;
    final event = ListEvent.many(iterable.map((v) {
      return ListEvent.insert(offset++, v);
    }).toList());
    apply(event);
  }

  @override
  void fillRange(int start, int end, [E? fillValue]) {
    ListEvent.many(Iterable<int>.generate(end - start)
        .map((index) => ListEvent.insert(index + start, fillValue))
        .toList());
  }

  @override
  void insertAll(int index, Iterable<E?> iterable) {
    int offset = index;
    final event = ListEvent.many(iterable.map((v) {
      return ListEvent.insert(offset++, v);
    }).toList());
    apply(event);
  }

  //
  // REMOVE SINGLE

  @override
  bool remove(Object? value) {
    if (value is E) {
      final index = _inner.indexOf(value);
      if (index != -1) {
        apply(ListEvent.remove(index, value));
        return true;
      }
    }
    return false;
  }

  @override
  E? removeAt(int index) {
    final value = _inner[index];
    apply(ListEvent.remove(index, value));
    return value;
  }

  @override
  E? removeLast() {
    return removeAt(_inner.length - 1);
  }

  //
  // REMOVE MANY

  @override
  void clear() {
    removeRange(0, _inner.length);
  }

  @override
  void removeRange(int start, int end) {
    final event = ListEvent.many(Iterable<int>.generate(end - start)
        .map((index) => ListEvent.remove(index + start, _inner[index + start]))
        .toList());
    apply(event);
  }

  @override
  void removeWhere(bool Function(E element) test) {
    // TODO: implement removeWhere
  }

  @override
  void retainWhere(bool Function(E element) test) {
    removeWhere((e) => !test(e));
  }

  @override
  void setAll(int index, Iterable<E?> iterable) {
    // TODO: implement setAll
  }

  //
  // CHANGE SINGLE

  @override
  void operator []=(int index, E? value) {
    _inner[index] = value;
  }

  @override
  set first(E? value) {
    _inner.first = value;
  }

  @override
  set last(E? value) {
    _inner.last = value;
  }

  //
  // CHANGE MANY

  @override
  void replaceRange(int start, int end, Iterable<E?> replacement) {
    // TODO: implement replaceRange
  }

  @override
  void setRange(int start, int end, Iterable<E?> iterable,
      [int skipCount = 0]) {
    // TODO: implement setRange
  }

  //
  // REORDER

  @override
  void shuffle([Random? random]) {
    // TODO: implement shuffle
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    // TODO: implement sort
  }

  @override
  bool any(bool Function(E? element) test) => _inner.any(test);

  @override
  Map<int, E?> asMap() => _inner.asMap();

  @override
  List<R> cast<R>() => _inner.cast();

  @override
  bool contains(Object? element) => _inner.contains(element);

  @override
  E? elementAt(int index) => _inner.elementAt(index);

  @override
  bool every(bool Function(E? element) test) => _inner.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E? element) f) => _inner.expand(f);

  @override
  E? firstWhere(bool Function(E? element) test, {E? Function()? orElse}) =>
      _inner.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E? element) combine) =>
      _inner.fold(initialValue, combine);

  @override
  Iterable<E?> followedBy(Iterable<E?> other) => _inner.followedBy(other);

  @override
  void forEach(void Function(E? element) f) => _inner.forEach(f);

  @override
  Iterable<E?> getRange(int start, int end) => _inner.getRange(start, end);

  @override
  int indexOf(E? element, [int start = 0]) => _inner.indexOf(element, start);

  @override
  int indexWhere(bool Function(E? element) test, [int start = 0]) =>
      _inner.indexWhere(test, start);

  @override
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  Iterator<E?> get iterator => _inner.iterator;

  @override
  String join([String separator = '']) => _inner.join(separator);

  @override
  int lastIndexOf(E? element, [int? start]) =>
      _inner.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool Function(E? element) test, [int? start]) =>
      _inner.lastIndexWhere(test, start);

  @override
  E? lastWhere(bool Function(E? element) test, {E? Function()? orElse}) =>
      _inner.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(E? e) f) => _inner.map(f);

  @override
  E? reduce(E? Function(E? value, E? element) combine) =>
      _inner.reduce(combine);

  @override
  Iterable<E?> get reversed => _inner.reversed;

  @override
  E? get single => _inner.single;

  @override
  E? singleWhere(bool Function(E? element) test, {E? Function()? orElse}) =>
      _inner.singleWhere(test, orElse: orElse);

  @override
  Iterable<E?> skip(int count) => _inner.skip(count);

  @override
  Iterable<E?> skipWhile(bool Function(E? value) test) =>
      _inner.skipWhile(test);

  @override
  List<E?> sublist(int start, [int? end]) => _inner.sublist(start, end);

  @override
  Iterable<E?> take(int count) => _inner.take(count);

  @override
  Iterable<E?> takeWhile(bool Function(E? value) test) =>
      _inner.takeWhile(test);

  @override
  List<E?> toList({bool growable = true}) => _inner.toList(growable: growable);

  @override
  Set<E?> toSet() => _inner.toSet();

  @override
  Iterable<E?> where(bool Function(E? element) test) => _inner.where(test);

  @override
  Iterable<T> whereType<T>() => _inner.whereType<T>();

  @override
  E? get first => _inner.first;

  @override
  E? get last => _inner.last;

  @override
  int get length => _inner.length;
}
