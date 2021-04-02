import 'dart:async';

import 'file_system_write_chunk_type.dart';

enum PermissionStateEnum { granted, denied, prompt }

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

class FilePickerAcceptType {
  const FilePickerAcceptType({this.description, required this.accept});
  final String? description; //@optional
  final Map<String, List<String> /*String | String[]*/ > accept;
}

enum FileSystemPermissionMode {
  read,
  readwrite,
}

enum FileSystemHandleKind { file, directory }

abstract class FileSystemWritableFileStream {
  Future<void> write(FileSystemWriteChunkType data);

  Future<void> close();

  Future<void> seek(int position);

  Future<void> truncate(int size);
}

abstract class FileSystemFileHandle extends FileSystemHandle {
  Future<dynamic /*html.File*/ > getFile();
  Future<FileSystemWritableFileStream> createWritable({bool? keepExistingData});
}

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

  Future<List<String>? /*@optional*/ > resolve(
    FileSystemHandle possibleDescendant,
  );
}

abstract class FileSystem extends FileSystemI {
  static const FileSystem? instance = null;
}

abstract class FileSystemI {
  const FileSystemI();

  Future<String?> readFileAsText(dynamic /*html.File*/ file);

  Future<List<FileSystemFileHandle>> showOpenFilePicker({
    List<FilePickerAcceptType>? types,
    bool? excludeAcceptAllOption,
    bool? multiple,
  });

  Future<FileSystemFileHandle> showSaveFilePicker({
    List<FilePickerAcceptType>? types,
    bool? excludeAcceptAllOption,
  });

  Future<FileSystemDirectoryHandle> showDirectoryPicker();

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
