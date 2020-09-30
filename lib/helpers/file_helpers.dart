import 'dart:io';

class FileHelpers {
  static bool isDirectory(File file) =>
      FileSystemEntity.typeSync(file.path) == FileSystemEntityType.directory;

  static String getName(File file) => file?.absolute?.path?.split("\\")?.last;

  static String getClassNameFromFolder(File file) =>
      getName(file).substring(0, 1).toUpperCase() + getName(file).substring(1);

  static List<File> listFiles(File folder) {
    Directory directory = Directory(folder.path);
    return directory.listSync().map<File>((a) => File(a.path)).toList();
  }

  static String prepareFiledName({
    File file,
    String name,
  }) {
    return (name ?? getName(file))
        .replaceAll("-", "_")
        .replaceAll(" ", "_")
        .replaceAll(".", "_");
  }

  static int compare(File a, File b) {
    return getName(a).compareTo(getName(b));
  }
}
