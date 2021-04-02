// Type definitions for non-npm package File System Access API 2020.09
// Project: https://github.com/WICG/file-system-access
// Definitions by: Ingvar Stepanyan <https://github.com/RReverser>
// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped
// Minimum TypeScript Version: 3.5
@JS()
library file_system_access;

import 'dart:async';

import "package:js/js.dart";
import 'package:neural_graph/common/extensions.dart';
import 'dart:html' as html;

import 'package:neural_graph/file_system_access_chrome/file_system_write_chunk_type.dart';

import 'file_system_access_interface.dart';

export 'package:neural_graph/file_system_access_chrome/file_system_write_chunk_type.dart';

// @JS()
// @anonymous
// class JsBlob {
//   external String get type;
//   external int get size;

//   // external JsBlob slice();
// }

// @JS()
// @anonymous
// class JsFile extends JsBlob {
//   external String get webkitRelativePath;
//   external String get name;
//   external DateTime get lastModifiedDate;
//   external int get lastModified;
// }

// @JS("FileReader")
// class _JsFileReader {
//   external String get error;
//   external int get readyState;
//   external dynamic get result;

//   external void Function() get onabort;
//   external set onabort(void Function() f);
//   external void Function() get onerror;
//   external set onerror(void Function() f);
//   external void Function() get onload;
//   external set onload(void Function() f);
//   external void Function() get onloadstart;
//   external set onloadstart(void Function() f);
//   external void Function() get onloadend;
//   external set onloadend(void Function() f);
//   external void Function() get onprogress;
//   external set onprogress(void Function() f);

//   external void abort();
//   external void readAsArrayBuffer(JsBlob blob);
//   external void readAsBinaryString(JsBlob blob);
//   external void readAsDataUrl(JsBlob blob);
//   external void readAsText(JsBlob blob);
// }

@JS()
@anonymous
class _Promise<T> {
  external _Promise<V> then<V>(V Function(T) f);
  @JS("catch")
  external _Promise<T> catchFn(void Function(dynamic) f);
}

@JS('BaseFileSystemHandle')
abstract class _FileSystemHandle {
  // protected constructor();

  external String get kind;
  external String get name;

  external _Promise<bool> isSameEntry(_FileSystemHandle other);
  external _Promise<String /*PermissionStateEnum*/> queryPermission(
      [_FileSystemHandlePermissionDescriptor? descriptor]);
  external _Promise<String /*PermissionStateEnum*/> requestPermission(
      [_FileSystemHandlePermissionDescriptor? descriptor]);

  // /**
  //  * @deprecated Old property just for Chromium <=85. Use `kind` property in the new API.
  //  */
  // readonly isFile: this['kind'] extends 'file' ? true : false;

  // /**
  //  * @deprecated Old property just for Chromium <=85. Use `kind` property in the new API.
  //  */
  // readonly isDirectory: this['kind'] extends 'directory' ? true : false;
}

abstract class _FileSystemHandleJS implements FileSystemHandle {
  const _FileSystemHandleJS(this.inner);
  final _FileSystemHandle inner;

  @override
  Future<bool> isSameEntry(FileSystemHandle other) =>
      _ptf(inner.isSameEntry((other as _FileSystemHandleJS).inner));

  @override
  FileSystemHandleKind get kind => inner.kind == "directory"
      ? FileSystemHandleKind.directory
      : FileSystemHandleKind.file;

  @override
  String get name => inner.name;

  @override
  Future<PermissionStateEnum> queryPermission(
          {FileSystemPermissionMode? mode}) =>
      _ptf(inner.queryPermission(
        _FileSystemHandlePermissionDescriptor(
          mode: mode == null ? null : mode.toString().split(".")[1],
        ),
      )).then((value) => parseEnum(value, PermissionStateEnum.values)!);

  @override
  Future<PermissionStateEnum> requestPermission(
          {FileSystemPermissionMode? mode}) =>
      _ptf(inner.requestPermission(
        _FileSystemHandlePermissionDescriptor(
          mode: mode == null ? null : mode.toString().split(".")[1],
        ),
      )).then((value) => parseEnum(value, PermissionStateEnum.values)!);
}

@JS()
@anonymous
class FilePickerAcceptTypeJS {
  external factory FilePickerAcceptTypeJS({
    String? description,
    required Map<String, List<String>> accept,
  });
  external String? get description; //@optional
  external Map<String, List<String>/*String | String[]*/ > get accept;
}

@JS()
@anonymous
class _FilePickerOptions {
  external factory _FilePickerOptions({
    List<FilePickerAcceptTypeJS>? types,
    bool? excludeAcceptAllOption,
  });
  external List<FilePickerAcceptTypeJS>? get types; //@optional
  external bool? get excludeAcceptAllOption; //@optional
}

@JS()
@anonymous
class _OpenFilePickerOptions {
  external factory _OpenFilePickerOptions({
    bool? multiple,
    List<FilePickerAcceptTypeJS>? types,
    bool? excludeAcceptAllOption,
  });
  external bool? get multiple; //@optional
  external List<FilePickerAcceptTypeJS>? get types; //@optional
  external bool? get excludeAcceptAllOption; //@optional
}

// tslint:disable-next-line:no-empty-interface
// TODO: can't extend
// class SaveFilePickerOptions extends FilePickerOptions {}

// tslint:disable-next-line:no-empty-interface
// @JS()
// @anonymous
// class _DirectoryPickerOptions {
//   external factory _DirectoryPickerOptions();
// }

// @JS()
// @anonymous
// class FileSystemPermissionDescriptor /*extends PermissionDescriptor*/ {
//   external factory FileSystemPermissionDescriptor(
//       {FileSystemHandle handle, FileSystemPermissionMode mode});
//   external FileSystemHandle get handle;
//   external FileSystemPermissionMode get mode; //@optional
// }

@JS()
@anonymous
class _FileSystemHandlePermissionDescriptor {
  external factory _FileSystemHandlePermissionDescriptor({String? mode});

  // factory FileSystemHandlePermissionDescriptor.read() =>
  //     FileSystemHandlePermissionDescriptor(mode: "read");
  // factory FileSystemHandlePermissionDescriptor.readwrite() =>
  //     FileSystemHandlePermissionDescriptor(mode: "readwrite");

  external String? get mode; //@optional
}

@JS()
@anonymous
class _FileSystemCreateWritableOptions {
  external factory _FileSystemCreateWritableOptions({bool? keepExistingData});
  external bool? get keepExistingData; //@optional
}

@JS()
@anonymous
class _FileSystemGetFileOptions {
  external factory _FileSystemGetFileOptions({bool? create});
  external bool? get create; //@optional
}

@JS()
@anonymous
class _FileSystemGetDirectoryOptions {
  external factory _FileSystemGetDirectoryOptions({bool? create});
  external bool? get create; //@optional
}

@JS()
@anonymous
class _FileSystemRemoveOptions {
  external factory _FileSystemRemoveOptions({bool? recursive});
  external bool? get recursive; //@optional
}

/// impl in [WriteParams]
@JS()
@anonymous
class _WriteParams {
  external factory _WriteParams({
    required String? type,
    int? position,
    dynamic data,
    int? size,
  });

  external String get type;
  external int? get position;
  external dynamic/*?*/ get data;
  external int? get size;
}

// type WriteParams =
//     | { type: 'write'; position?: number; data: BufferSource | Blob | string }
//     | { type: 'seek'; position: number }
//     | { type: 'truncate'; size: number };

// type FileSystemWriteChunkType = BufferSource | Blob | string | WriteParams;

// TODO: remove this once https://github.com/microsoft/TSJS-lib-generator/issues/881 is fixed.
// Native File System API especially needs this method.
// @JS()
// @anonymous
// abstract class WritableStream {
//   external _Promise<void> close();
// }

//@class
@JS("FileSystemWritableFileStream")
abstract class _FileSystemWritableFileStream /*extends WritableStream*/ {
  external _Promise<void> close();
  external _Promise<void> write(dynamic /*FileSystemWriteChunkType*/ data);
  external _Promise<void> seek(int position);
  external _Promise<void> truncate(int size);
}

class FileSystemWritableFileStreamJS implements FileSystemWritableFileStream {
  const FileSystemWritableFileStreamJS(this.inner);
  final _FileSystemWritableFileStream inner;

  @override
  Future<void> write(FileSystemWriteChunkType data) {
    return _ptf(inner.write(
      data.maybeWhen(
        writeParams: (writeParams) {
          final map = writeParams.toJson();
          return _WriteParams(
            type: map["type"] as String?,
            position: map["position"] as int?,
            data: map["data"],
            size: map["size"] as int?,
          );
        },
        orElse: () => data.value,
      ),
    ));
  }

  @override
  Future<void> close() => _ptf(inner.close());

  @override
  Future<void> seek(int position) => _ptf(inner.seek(position));

  @override
  Future<void> truncate(int size) => _ptf(inner.truncate(size));
}

// const FileSystemHandle: typeof BaseFileSystemHandle;
// type FileSystemHandle = FileSystemFileHandle | FileSystemDirectoryHandle;

//@class
@JS("FileSystemFileHandle")
abstract class _FileSystemFileHandle extends _FileSystemHandle {
  external _Promise<html.File> getFile();
  external _Promise<_FileSystemWritableFileStream> createWritable(
      [_FileSystemCreateWritableOptions? options]);
}

class FileSystemFileHandleJS extends _FileSystemHandleJS
    implements FileSystemFileHandle {
  const FileSystemFileHandleJS(_FileSystemFileHandle inner) : super(inner);
  _FileSystemFileHandle get _inner => inner as _FileSystemFileHandle;

  @override
  Future<html.File> getFile() => _ptf(_inner.getFile());
  @override
  Future<FileSystemWritableFileStream> createWritable(
          {bool? keepExistingData}) =>
      _ptf(_inner.createWritable(_FileSystemCreateWritableOptions(
              keepExistingData: keepExistingData)))
          .then((value) => FileSystemWritableFileStreamJS(value));
}

//@class
@JS("FileSystemDirectoryHandle")
abstract class _FileSystemDirectoryHandle extends _FileSystemHandle {
  external _Promise<_FileSystemFileHandle> getFileHandle(String name,
      [_FileSystemGetFileOptions? options]);
  external _Promise<_FileSystemWritableFileStream> getDirectoryHandle(
      String name,
      [_FileSystemGetDirectoryOptions? options]);
  external _Promise<void> removeEntry(String name,
      [_FileSystemRemoveOptions? options]);
  external _Promise<List<String>? /*@optional*/ > resolve(
      FileSystemHandle possibleDescendant);

  // AsyncIterableIterator<string> keys();
  // AsyncIterableIterator<FileSystemHandle> values();
  // AsyncIterableIterator<[string, FileSystemHandle]> entries();
  // [Symbol.asyncIterator]: FileSystemDirectoryHandle['entries'];

  // /**
  //  * @deprecated Old method just for Chromium <=85. Use `navigator.storage.getDirectory()` in the new API.
  //  */
  // static getSystemDirectory(options: GetSystemDirectoryOptions): Promise<FileSystemDirectoryHandle>;
}

class FileSystemDirectoryHandleJS extends _FileSystemHandleJS
    implements FileSystemDirectoryHandle {
  const FileSystemDirectoryHandleJS(_FileSystemDirectoryHandle inner)
      : super(inner);
  _FileSystemDirectoryHandle get _inner => inner as _FileSystemDirectoryHandle;

  @override
  Future<FileSystemFileHandle> getFileHandle(String name, {bool? create}) =>
      _ptf(_inner.getFileHandle(name, _FileSystemGetFileOptions(create: create)))
          .then((value) => FileSystemFileHandleJS(value));

  @override
  Future<FileSystemWritableFileStream> getDirectoryHandle(String name,
          {bool? create}) =>
      _ptf(_inner.getDirectoryHandle(
              name, _FileSystemGetDirectoryOptions(create: create)))
          .then((value) => FileSystemWritableFileStreamJS(value));

  @override
  Future<void> removeEntry(String name, {bool? recursive}) => _ptf(
      _inner.removeEntry(name, _FileSystemRemoveOptions(recursive: recursive)));

  @override
  Future<List<String>? /*@optional*/ > resolve(
          FileSystemHandle possibleDescendant) =>
      _pltf(_inner.resolve(possibleDescendant));
}

// @JS()
// @anonymous
// class DataTransferItem {
//   external _Promise<
//       FileSystemHandle /*@optional*/
//       > getAsFileSystemHandle();
// }

// @JS()
// @anonymous
// class StorageManager {
//   external _Promise<FileSystemDirectoryHandle> getDirectory();
// }

@JS("showOpenFilePicker")
external _Promise<List<_FileSystemFileHandle>> _showOpenFilePicker(
    [_OpenFilePickerOptions? options]);

@JS("showSaveFilePicker")
external _Promise<_FileSystemFileHandle> _showSaveFilePicker(
    [/*Save*/ _FilePickerOptions? options]);

@JS("showDirectoryPicker")
external _Promise<_FileSystemDirectoryHandle> _showDirectoryPicker();

class FileSystem extends FileSystemI {
  const FileSystem._();

  static const FileSystem instance = FileSystem._();

  @override
  Future<String?> readFileAsText(dynamic file) {
    final reader = html.FileReader();
    final completer = Completer<String?>();
    void _c(String? v) => !completer.isCompleted ? completer.complete(v) : null;

    reader.onLoad.listen((e) {
      _c(reader.result as String?);
    });
    reader.onError.listen((event) {
      _c(null);
    });
    reader.onAbort.listen((event) {
      _c(null);
    });

    // final reader = _JsFileReader();
    // final completer = Completer<String>();
    // void _c(String v) => !completer.isCompleted ? completer.complete(v) : null;
    // reader.onload = allowInterop(() {
    //   _c(reader.result as String);
    // });
    // reader.onerror = allowInterop(() {
    //   _c(null);
    // });
    // reader.onabort = allowInterop(() {
    //   _c(null);
    // });
    reader.readAsText(file as html.File);

    return completer.future;
  }

  @override
  Future<List<FileSystemFileHandle>> showOpenFilePicker({
    List<FilePickerAcceptType>? types,
    bool? excludeAcceptAllOption,
    bool? multiple,
  }) =>
      _pltf(_showOpenFilePicker(_OpenFilePickerOptions(
        multiple: multiple,
        excludeAcceptAllOption: excludeAcceptAllOption,
        types: _mapFilePickerTypes(types),
      ))).then(
        (value) => value.map((e) => FileSystemFileHandleJS(e)).toList(),
      );

  @override
  Future<FileSystemFileHandle> showSaveFilePicker({
    List<FilePickerAcceptType>? types,
    bool? excludeAcceptAllOption,
  }) =>
      _ptf(
        _showSaveFilePicker(_FilePickerOptions(
          excludeAcceptAllOption: excludeAcceptAllOption,
          types: _mapFilePickerTypes(types),
        )),
      ).then((value) => FileSystemFileHandleJS(value));

  @override
  Future<FileSystemDirectoryHandle> showDirectoryPicker() =>
      _ptf(_showDirectoryPicker())
          .then((value) => FileSystemDirectoryHandleJS(value));
}

List<FilePickerAcceptTypeJS>? _mapFilePickerTypes(
    List<FilePickerAcceptType>? list) {
  if (list == null) {
    return null;
  }
  return list
      .map((e) => FilePickerAcceptTypeJS(
            accept: e.accept,
            description: e.description,
          ))
      .toList();
}

/// Converts a JavaScript Promise to a Dart [Future].
///
/// ```dart
/// @JS()
/// external Promise<num> get threePromise; // Resolves to 3
///
/// final Future<num> threeFuture = promiseToFuture(threePromise);
///
/// final three = await threeFuture; // == 3
/// ```
Future<T> promiseToFuture<T>(_Promise<T> jsPromise) {
  final completer = Completer<T>();

  final success = allowInterop((r) => completer.complete(r as T?));
  final error = allowInterop((e) => completer.completeError(e as Object));

  jsPromise.then(success).catchFn(error);
  return completer.future;
}

Future<T> _ptf<T>(_Promise<T> v) async {
  final vm = await promiseToFuture(v);
  return vm as T;
}

Future<List<T>> _pltf<T>(_Promise<List<T>?> v) async {
  final vm = await promiseToFuture(v as _Promise<List<T>>);
  return (vm as List).cast();
}

// DEPRECATED
// Old methods available on Chromium 85 instead of the ones above.

// class ChooseFileSystemEntriesOptionsAccepts {
//     description?: string;
//     mimeTypes?: string[];
//     extensions?: string[];
// }

// class ChooseFileSystemEntriesFileOptions {
//     accepts?: ChooseFileSystemEntriesOptionsAccepts[];
//     excludeAcceptAllOption?: boolean;
// }

// /**
//  * @deprecated Old method just for Chromium <=85. Use `showOpenFilePicker()` in the new API.
//  */
// function chooseFileSystemEntries(
//     options?: ChooseFileSystemEntriesFileOptions & {
//         type?: 'open-file';
//         multiple?: false;
//     },
// ): Promise<FileSystemFileHandle>;
// /**
//  * @deprecated Old method just for Chromium <=85. Use `showOpenFilePicker()` in the new API.
//  */
// function chooseFileSystemEntries(
//     options: ChooseFileSystemEntriesFileOptions & {
//         type?: 'open-file';
//         multiple: true;
//     },
// ): Promise<FileSystemFileHandle[]>;
// /**
//  * @deprecated Old method just for Chromium <=85. Use `showSaveFilePicker()` in the new API.
//  */
// function chooseFileSystemEntries(
//     options: ChooseFileSystemEntriesFileOptions & {
//         type: 'save-file';
//     },
// ): Promise<FileSystemFileHandle>;
// /**
//  * @deprecated Old method just for Chromium <=85. Use `showDirectoryPicker()` in the new API.
//  */
// function chooseFileSystemEntries(options: { type: 'open-directory' }): Promise<FileSystemDirectoryHandle>;

// class GetSystemDirectoryOptions {
//     type: 'sandbox';
// }

// class FileSystemDirectoryHandle {
//     /**
//      * @deprecated Old property just for Chromium <=85. Use `.getFileHandle()` in the new API.
//      */
//     getFile: FileSystemDirectoryHandle['getFileHandle'];

//     /**
//      * @deprecated Old property just for Chromium <=85. Use `.getDirectoryHandle()` in the new API.
//      */
//     getDirectory: FileSystemDirectoryHandle['getDirectoryHandle'];

//     /**
//      * @deprecated Old property just for Chromium <=85. Use `.keys()`, `.values()`, `.entries()`, or the directory itself as an async iterable in the new API.
//      */
//     getEntries: FileSystemDirectoryHandle['values'];
// }

// class FileSystemHandlePermissionDescriptor {
//     /**
//      * @deprecated Old property just for Chromium <=85. Use `mode: ...` in the new API.
//      */
//     writable?: boolean;
// }
