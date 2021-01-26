// Type definitions for non-npm package File System Access API 2020.09
// Project: https://github.com/WICG/file-system-access
// Definitions by: Ingvar Stepanyan <https://github.com/RReverser>
// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped
// Minimum TypeScript Version: 3.5
@JS()
library file_system_access;

import 'dart:async';
import 'dart:js_util';

import "package:js/js.dart";
import 'package:meta/meta.dart';
import 'package:neural_graph/common/extensions.dart';
import 'dart:html' as html;

import 'package:neural_graph/file_system_access_chrome/file_system_write_chunk_type.dart';

export 'package:neural_graph/file_system_access_chrome/file_system_write_chunk_type.dart';

@JS()
@anonymous
class _PermissionState {}

enum PermissionStateEnum { granted, denied, prompt }

@JS()
@anonymous
class _Promise<T> {}

@JS('BaseFileSystemHandle')
abstract class _FileSystemHandle {
  // protected constructor();

  external String get kind;
  external String get name;

  external _Promise<bool> isSameEntry(_FileSystemHandle other);
  external _Promise<String> queryPermission(
      [FileSystemHandlePermissionDescriptor descriptor]);
  external _Promise<String> requestPermission(
      [FileSystemHandlePermissionDescriptor descriptor]);

  // /**
  //  * @deprecated Old property just for Chromium <=85. Use `kind` property in the new API.
  //  */
  // readonly isFile: this['kind'] extends 'file' ? true : false;

  // /**
  //  * @deprecated Old property just for Chromium <=85. Use `kind` property in the new API.
  //  */
  // readonly isDirectory: this['kind'] extends 'directory' ? true : false;
}

Future<bool> verifyPermission(
  FileSystemHandle fileHandle, {
  @required bool readWrite,
}) async {
  FileSystemHandlePermissionDescriptor options;
  if (readWrite) {
    options = FileSystemHandlePermissionDescriptor(mode: "readwrite");
  }
  // Check if permission was already granted. If so, return true.
  if (await fileHandle.queryPermission(options) ==
      PermissionStateEnum.granted) {
    return true;
  }
  // Request permission. If the user grants permission, return true.
  if (await fileHandle.requestPermission(options) ==
      PermissionStateEnum.granted) {
    return true;
  }
  // The user didn't grant permission, so return false.
  return false;
}

abstract class FileSystemHandle {
  const FileSystemHandle(this.inner);
  final _FileSystemHandle inner;

  Future<bool> isSameEntry(FileSystemHandle other) =>
      _ptf(inner.isSameEntry(other.inner));

  FileSystemHandleKind get kind => inner.kind == "directory"
      ? FileSystemHandleKind.directory
      : FileSystemHandleKind.file;

  String get name => inner.name;

  Future<PermissionStateEnum> queryPermission(
          [FileSystemHandlePermissionDescriptor descriptor]) =>
      _ptf(inner.queryPermission(descriptor))
          .then((value) => parseEnum(value, PermissionStateEnum.values));

  Future<PermissionStateEnum> requestPermission(
          [FileSystemHandlePermissionDescriptor descriptor]) =>
      _ptf(inner.requestPermission(descriptor))
          .then((value) => parseEnum(value, PermissionStateEnum.values));
}

@JS()
@anonymous
class FilePickerAcceptType {
  external factory FilePickerAcceptType({String description});
  external String get description; //@optional
  external Map<String, dynamic /*String | String[]*/ > get accept;
}

@JS()
@anonymous
class FilePickerOptions {
  external factory FilePickerOptions({List<FilePickerAcceptType> types});
  external List<FilePickerAcceptType> get types; //@optional
  external bool get excludeAcceptAllOption; //@optional
}

@JS()
@anonymous
class OpenFilePickerOptions extends FilePickerOptions {
  external factory OpenFilePickerOptions({bool multiple});
  external bool get multiple; //@optional
}

// tslint:disable-next-line:no-empty-interface
// TODO: can't extend
// class SaveFilePickerOptions extends FilePickerOptions {}

// tslint:disable-next-line:no-empty-interface
@JS()
@anonymous
class DirectoryPickerOptions {
  external factory DirectoryPickerOptions();
}

// TODO: type FileSystemPermissionMode = 'read' | 'readwrite';
// enum FileSystemPermissionMode {
//   read,
//   readwrite,
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
class FileSystemHandlePermissionDescriptor {
  // TODO: improve external api
  external factory FileSystemHandlePermissionDescriptor({String mode});

  // factory FileSystemHandlePermissionDescriptor.read() =>
  //     FileSystemHandlePermissionDescriptor(mode: "read");
  // factory FileSystemHandlePermissionDescriptor.readwrite() =>
  //     FileSystemHandlePermissionDescriptor(mode: "readwrite");

  external String get mode; //@optional
}

// TODO: type FileSystemHandleKind = 'file' | 'directory';
enum FileSystemHandleKind { file, directory }

@JS()
@anonymous
class FileSystemCreateWritableOptions {
  external factory FileSystemCreateWritableOptions({bool keepExistingData});
  external bool get keepExistingData; //@optional
}

@JS()
@anonymous
class FileSystemGetFileOptions {
  external factory FileSystemGetFileOptions({bool create});
  external bool get create; //@optional
}

@JS()
@anonymous
class FileSystemGetDirectoryOptions {
  external factory FileSystemGetDirectoryOptions({bool create});
  external bool get create; //@optional
}

@JS()
@anonymous
class FileSystemRemoveOptions {
  external factory FileSystemRemoveOptions({bool recursive});
  external bool get recursive; //@optional
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

class FileSystemWritableFileStream {
  const FileSystemWritableFileStream(this.inner);
  final _FileSystemWritableFileStream inner;

  Future<void> write(FileSystemWriteChunkType data) {
    return _ptf(inner.write(
      data.maybeWhen(
        writeParams: (writeParams) => jsify(writeParams.toJson()),
        orElse: () => data.value,
      ),
    ));
  }

  Future<void> close() => _ptf(inner.close());

  Future<void> seek(int position) => _ptf(inner.seek(position));

  Future<void> truncate(int size) => _ptf(inner.truncate(size));
}

// const FileSystemHandle: typeof BaseFileSystemHandle;
// type FileSystemHandle = FileSystemFileHandle | FileSystemDirectoryHandle;

//@class
@JS("FileSystemFileHandle")
abstract class _FileSystemFileHandle extends _FileSystemHandle {
  external _Promise<html.File> getFile();
  external _Promise<_FileSystemWritableFileStream> createWritable(
      [FileSystemCreateWritableOptions options]);
}

class FileSystemFileHandle extends FileSystemHandle {
  const FileSystemFileHandle(_FileSystemFileHandle inner) : super(inner);
  _FileSystemFileHandle get _inner => inner as _FileSystemFileHandle;

  Future<html.File> getFile() => _ptf(_inner.getFile());
  Future<FileSystemWritableFileStream> createWritable(
          [FileSystemCreateWritableOptions options]) =>
      _ptf(_inner.createWritable(options))
          .then((value) => FileSystemWritableFileStream(value));
}

//@class
@JS("FileSystemDirectoryHandle")
abstract class _FileSystemDirectoryHandle extends _FileSystemHandle {
  external _Promise<_FileSystemFileHandle> getFileHandle(String name,
      [FileSystemGetFileOptions options]);
  external _Promise<_FileSystemWritableFileStream> getDirectoryHandle(
      String name,
      [FileSystemGetDirectoryOptions options]);
  external _Promise<void> removeEntry(String name,
      [FileSystemRemoveOptions options]);
  external _Promise<List<String> /*@optional*/ > resolve(
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

class FileSystemDirectoryHandle extends FileSystemHandle {
  const FileSystemDirectoryHandle(_FileSystemDirectoryHandle inner)
      : super(inner);
  _FileSystemDirectoryHandle get _inner => inner as _FileSystemDirectoryHandle;

  Future<FileSystemFileHandle> getFileHandle(String name,
          [FileSystemGetFileOptions options]) =>
      _ptf(_inner.getFileHandle(name, options))
          .then((value) => FileSystemFileHandle(value));

  Future<FileSystemWritableFileStream> getDirectoryHandle(String name,
          [FileSystemGetDirectoryOptions options]) =>
      _ptf(_inner.getDirectoryHandle(name, options))
          .then((value) => FileSystemWritableFileStream(value));

  Future<void> removeEntry(String name, [FileSystemRemoveOptions options]) =>
      _ptf(_inner.removeEntry(name, options));

  Future<List<String> /*@optional*/ > resolve(
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

Future<String> readFileAsText(html.File file) {
  final reader = html.FileReader();
  final completer = Completer<String>();
  void _c(String v) => !completer.isCompleted ? completer.complete(v) : null;

  reader.onLoad.listen((e) {
    _c(reader.result as String);
  });
  reader.onError.listen((event) {
    _c(null);
  });
  reader.onAbort.listen((event) {
    _c(null);
  });
  reader.readAsText(file);

  return completer.future;
}

// function showOpenFilePicker(
//     options?: OpenFilePickerOptions & { multiple?: false },
// ): Promise<[FileSystemFileHandle]>;
Future<List<FileSystemFileHandle>> showOpenFilePicker(
        [OpenFilePickerOptions options]) =>
    _pltf(_showOpenFilePicker(options))
        .then((value) => value.map((e) => FileSystemFileHandle(e)).toList());

@JS("showOpenFilePicker")
external _Promise<List<_FileSystemFileHandle>> _showOpenFilePicker(
    [OpenFilePickerOptions options]);

Future<FileSystemFileHandle> showSaveFilePicker(
        [/*Save*/ FilePickerOptions options]) =>
    _ptf(_showSaveFilePicker(options))
        .then((value) => FileSystemFileHandle(value));

@JS("showSaveFilePicker")
external _Promise<_FileSystemFileHandle> _showSaveFilePicker(
    [/*Save*/ FilePickerOptions options]);

Future<FileSystemDirectoryHandle> showDirectoryPicker(
        [DirectoryPickerOptions options]) =>
    _ptf(_showDirectoryPicker(options))
        .then((value) => FileSystemDirectoryHandle(value));

@JS("showDirectoryPicker")
external _Promise<_FileSystemDirectoryHandle> _showDirectoryPicker(
    [DirectoryPickerOptions options]);

Future<T> _ptf<T>(_Promise<T> v) async {
  final vm = await promiseToFuture(v);
  return vm as T;
}

Future<List<T>> _pltf<T>(_Promise<List<T>> v) async {
  final vm = await promiseToFuture(v);
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
