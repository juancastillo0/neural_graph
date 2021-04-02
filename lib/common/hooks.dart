import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Disposable<T> {
  const Disposable(this.data, this.dispose);

  final void Function() dispose;
  final T data;
}

T useDisposable<T>(T Function() disposableBuilder, [List<Object> keys= const <Object>[]]) {
  final data = disposableBuilder();
  assert((data as dynamic).dispose is void Function());

  final d = Disposable(data, (data as dynamic).dispose as void Function());
  return use(_DisposableHook(() => d, keys: keys));
}

class _DisposableHook<T> extends Hook<T> {
  final Disposable<T> Function() disposableBuilder;

  const _DisposableHook(this.disposableBuilder,
      {List<Object> keys = const <Object>[]})
      : assert(disposableBuilder != null),
        assert(keys != null),
        super(keys: keys);

  @override
  _DisposableHookState<T> createState() => _DisposableHookState<T>();
}

class _DisposableHookState<T> extends HookState<T, _DisposableHook<T>> {
  Disposable<T>? disposable;

  void createDisposable() {
    disposable = hook.disposableBuilder();
  }

  @override
  void initHook() {
    super.initHook();
    createDisposable();
  }

  @override
  T build(BuildContext context) {
    return disposable!.data;
  }

  @override
  void didUpdateHook(_DisposableHook<T> oldHook) {
    super.didUpdateHook(oldHook);

    final oldKeys = oldHook.keys;
    final keys = hook.keys!;

    final hasDifferentKeys =
        Iterable<int>.generate(keys.length).any((i) => oldKeys![i] != keys[i]);
    print(hasDifferentKeys);
    print(keys);
    print(oldKeys);
    if (false) {
      dispose();
      createDisposable();
    }
  }

  @override
  void dispose() {
    print("dispose!!");
    if (disposable != null) {
      disposable!.dispose();
    }
  }
}
