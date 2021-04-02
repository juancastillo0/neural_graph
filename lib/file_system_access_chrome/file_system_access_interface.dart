import 'dart:async';

import 'file_system_write_chunk_type.dart';

enum PermissionStateEnum { granted, denied, prompt }

/// https://developer.mozilla.org/docs/Web/API/FileSystemHandle
abstract class FileSystemHandle {
  Future<bool> isSameEntry(FileSystemHandle other);

  FileSystemHandleKind get kind;

  String get name;

  Future<PermissionStateEnum> queryPermission({
    FileSystemPermissionMode? mode,
  });

  Future<PermissionStateEnum> requestPermission({
    FileSystemPermissionMode? mode,
  });
}

/// https://developer.mozilla.org/docs/Web/API/window/showOpenFilePicker
/// {
///   description: 'Images',
///   accept: {
///     'image/*': ['.png', '.gif', '.jpeg', '.jpg']
///   }
/// }
///
/// [description] An optional description of the category of files types allowed.
/// [accept] An Object with the keys set to the MIME type and the
/// values an Array of file extensions.
class FilePickerAcceptType {
  const FilePickerAcceptType({this.description, required this.accept});
  final String? description;
  final Map<String, List<String> /*String | String[]*/ > accept;
}

enum FileSystemPermissionMode {
  read,
  readwrite,
}

enum FileSystemHandleKind { file, directory }

/// https://developer.mozilla.org/docs/Web/API/FileSystemWritableFileStream
abstract class FileSystemWritableFileStream {
  Future<void> write(FileSystemWriteChunkType data);

  Future<void> close();

  Future<void> seek(int position);

  Future<void> truncate(int size);
}

/// https://developer.mozilla.org/docs/Web/API/FileSystemFileHandle
abstract class FileSystemFileHandle extends FileSystemHandle {
  Future<dynamic /*html.File*/ > getFile();
  Future<FileSystemWritableFileStream> createWritable({bool? keepExistingData});
}

/// https://developer.mozilla.org/docs/Web/API/FileSystemDirectoryHandle
abstract class FileSystemDirectoryHandle extends FileSystemHandle {
  Future<FileSystemFileHandle> getFileHandle(
    String name, {
    bool? create,
  });

  Future<FileSystemWritableFileStream> getDirectoryHandle(
    String name, {
    bool? create,
  });

  Future<void> removeEntry(
    String name, {
    bool? recursive,
  });

  Future<List<String>?> resolve(
    FileSystemHandle possibleDescendant,
  );
}

abstract class FileSystem extends FileSystemI {
  static const FileSystem? instance = null;
}

abstract class FileSystemI {
  const FileSystemI();

  Future<String?> readFileAsText(dynamic /*html.File*/ file);

  /// https://developer.mozilla.org/docs/Web/API/Window/showOpenFilePicker
  /// Exception AbortError
  Future<List<FileSystemFileHandle>> showOpenFilePicker({
    List<FilePickerAcceptType>? types,
    bool? excludeAcceptAllOption,
    bool? multiple,
  });

  /// https://developer.mozilla.org/docs/Web/API/Window/showSaveFilePicker
  /// Exception AbortError
  Future<FileSystemFileHandle> showSaveFilePicker({
    List<FilePickerAcceptType>? types,
    bool? excludeAcceptAllOption,
  });

  /// https://developer.mozilla.org/docs/Web/API/Window/showDirectoryPicker
  /// Exception AbortError
  Future<FileSystemDirectoryHandle> showDirectoryPicker();

  /// Utility function for querying and requesting permission if it hasn't been granted
  Future<bool> verifyPermission(
    FileSystemHandle fileHandle, {
    required FileSystemPermissionMode mode,
  }) async {
    // Check if permission was already granted. If so, return true.
    if (await fileHandle.queryPermission(mode: mode) ==
        PermissionStateEnum.granted) {
      return true;
    }
    // Request permission. If the user grants permission, return true.
    if (await fileHandle.requestPermission(mode: mode) ==
        PermissionStateEnum.granted) {
      return true;
    }
    // The user didn't grant permission, so return false.
    return false;
  }
}
