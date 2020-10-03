import 'package:path/path.dart' as Path;
import 'dart:io';

import 'package:resource_id/helpers/string_helpers.dart';

class FileHelpers {
  static bool isDirectory(FileSystemEntity fileSystemEntity) =>
      FileSystemEntity.typeSync(fileSystemEntity.path) ==
      FileSystemEntityType.directory;

  static String getName(FileSystemEntity fileSystemEntity) {
    return Path.basenameWithoutExtension(fileSystemEntity.path);
  }

  static String getClassNameFromFolder(FileSystemEntity fileSystemEntity) =>
      getName(fileSystemEntity).substring(0, 1).toUpperCase() +
      getName(fileSystemEntity).substring(1);

  static List<FileSystemEntity> listFiles(Directory folder) {
    return folder.listSync();
  }

  static String prepareFiledName(FileSystemEntity fileSystemEntity) =>
      StringHelpers.prepareName(getName(fileSystemEntity));

  static int compare(FileSystemEntity a, FileSystemEntity b) {
    return getName(a).compareTo(getName(b));
  }

  static String getSrcLineOfFileSystem(
      FileSystemEntity fileSystemEntity, String parentPath) {
    return "final String ${FileHelpers.prepareFiledName(fileSystemEntity)} = \"${parentPath}/${FileHelpers.getName(fileSystemEntity)}/${FileHelpers.getName(fileSystemEntity)}\";";
  }
}
