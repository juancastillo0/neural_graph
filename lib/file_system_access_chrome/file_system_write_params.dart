import 'package:neural_graph/file_system_access_chrome/file_system_write_chunk_type.dart';

abstract class WriteParams {
  const WriteParams._();

  const factory WriteParams.write({
    required FileSystemWriteChunkType data,
    int? position,
  }) = _Write;
  const factory WriteParams.seek({
    required int position,
  }) = _Seek;
  const factory WriteParams.truncate({
    required int size,
  }) = _Truncate;

  T when<T>({
    required T Function(FileSystemWriteChunkType data, int? position) write,
    required T Function(int position) seek,
    required T Function(int size) truncate,
  }) {
    final WriteParams v = this;
    if (v is _Write) return write(v.data, v.position);
    if (v is _Seek) return seek(v.position);
    if (v is _Truncate) return truncate(v.size);
    throw "";
  }

  T maybeWhen<T>({
    required T Function() orElse,
    T Function(FileSystemWriteChunkType data, int? position)? write,
    T Function(int position)? seek,
    T Function(int size)? truncate,
  }) {
    final WriteParams v = this;
    if (v is _Write)
      return write != null ? write(v.data, v.position) : orElse.call();
    if (v is _Seek) return seek != null ? seek(v.position) : orElse.call();
    if (v is _Truncate)
      return truncate != null ? truncate(v.size) : orElse.call();
    throw "";
  }

  T map<T>({
    required T Function(_Write value) write,
    required T Function(_Seek value) seek,
    required T Function(_Truncate value) truncate,
  }) {
    final WriteParams v = this;
    if (v is _Write) return write(v);
    if (v is _Seek) return seek(v);
    if (v is _Truncate) return truncate(v);
    throw "";
  }

  T maybeMap<T>({
    required T Function() orElse,
    T Function(_Write value)? write,
    T Function(_Seek value)? seek,
    T Function(_Truncate value)? truncate,
  }) {
    final WriteParams v = this;
    if (v is _Write) return write != null ? write(v) : orElse.call();
    if (v is _Seek) return seek != null ? seek(v) : orElse.call();
    if (v is _Truncate) return truncate != null ? truncate(v) : orElse.call();
    throw "";
  }
//   static WriteParams fromJson(Map<String, dynamic> map) {
//   switch (map["runtimeType"] as String) {
//     case '_Write': return _Write.fromJson(map);
//     case '_Seek': return _Seek.fromJson(map);
//     case '_Truncate': return _Truncate.fromJson(map);
//     default:
//       return null;
//   }
// }

  Map<String, dynamic> toJson();
}

class _Write extends WriteParams {
  final int? position;
  final FileSystemWriteChunkType data;

  const _Write({
    required this.data,
    this.position,
  }) : super._();

  // static _Write fromJson(Map<String, dynamic> map) {
  //   return _Write(
  //     data: dynamic.fromJson(map['data'] as Map<String, dynamic>),
  //     position: map['position'] as int,
  //   );
  // }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "write",
      "position": position,
      "data": data.value,
    };
  }
}

class _Seek extends WriteParams {
  final int position;

  const _Seek({
    required this.position,
  }) : super._();

  // static _Seek fromJson(Map<String, dynamic> map) {
  //   return _Seek(
  //     position: map['position'] as int,
  //   );
  // }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "seek",
      "position": position,
    };
  }
}

class _Truncate extends WriteParams {
  final int size;

  const _Truncate({
    required this.size,
  }) : super._();

  // static _Truncate fromJson(Map<String, dynamic> map) {
  //   return _Truncate(
  //     size: map['size'] as int,
  //   );
  // }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "truncate",
      "size": size,
    };
  }
}
