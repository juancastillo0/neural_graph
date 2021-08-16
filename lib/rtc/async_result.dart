import 'package:freezed_annotation/freezed_annotation.dart';

part 'async_result.freezed.dart';

@freezed
class AsyncResult<S, E> with _$AsyncResult<S, E> {
  const AsyncResult._();
  const factory AsyncResult.idle() = _Idle<S, E>;
  const factory AsyncResult.loading() = _Loading<S, E>;
  const factory AsyncResult.success(S value) = _Success<S, E>;
  const factory AsyncResult.error(E error) = _Error<S, E>;

  bool get isIdle => maybeWhen(orElse: () => false, idle: () => true);
  bool get isLoading => maybeWhen(orElse: () => false, loading: () => true);
  bool get isSuccess => maybeWhen(orElse: () => false, success: (_) => true);
  bool get isError => maybeWhen(orElse: () => false, error: (_) => true);

  S? get valueOrNull =>
      maybeWhen(orElse: () => null, success: (value) => value);
  E? get errorOrNull => maybeWhen(orElse: () => null, error: (error) => error);
}
