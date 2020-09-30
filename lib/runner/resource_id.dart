import 'dart:io';

import 'package:resource_id/helpers/file_helpers.dart';
import 'package:resource_id/helpers/string_helpers.dart';
import 'package:resource_id/models/flutter_model.dart';
import 'package:yaml/yaml.dart';

class ResourceId {
  static Future<void> run() async {
    ResourceId resourceId = ResourceId();
    resourceId._run();
  }

  void _run() {
    FlutterModel flutterModel = _readPubspecFile();
    _start(flutterModel);
  }

  FlutterModel _readPubspecFile() {
    File pubspec = File("../pubspec.yaml");
    String yaml = pubspec.readAsStringSync();
    YamlMap yamlMap = loadYaml(yaml);
    return FlutterModel.fromYamlMap(yamlMap);
  }

  final List<String> createdClass = [];
  final List<String> reservedFolderNameForIgnore =
      List.unmodifiable(["2.0x", "3.0x"]);

  File desFile;
  StringBuffer defResult;

  void _start(FlutterModel flutterModel) {
    bool createResult = _createBuildFile();
    if (!createResult) return;

    for (String filePath in flutterModel.assets) {
      _createAssets(filePath);
    }
    _createFontsClass(flutterModel.fonts);
    _createBaseClass();
    _finishBuild();
  }

  bool _createBuildFile() {
    desFile = Files.fromPath("build.dart");
    if (desFile.existsSync()) {
      desFile.delete();
    }
    try {
      desFile.createSync();
      defResult = new StringBuffer();
    } catch (e) {
      print("BUILDER ERROR:Can't create build file\n" + e.getMessage());
      return false;
    }
    return true;
  }

  void _createAssets(String assetPath) {
    Directory folder = Directories.fromPath(assetPath);
    if (!folder.existsSync()) {
      File file = Files.fromPath(assetPath);
      if (!FileHelpers.isDirectory(file)) {
        print("path " + assetPath + " is file which is not support yet");
      } else {
        print("File or folder with directory " + assetPath + " doesn't exist");
      }
      return;
    }
    String assetParent = StringHelpers.replaceLast(
        assetPath, "/" + FileHelpers.getName(folder), "");
    Directory parentFolder = Directories.fromPath(assetParent);
    _createDefaultRes(parentFolder, folder);
  }

  void _createDefaultRes(Directory rootFolder, Directory folder) {
    String className = "_" + FileHelpers.getClassNameFromFolder(folder);
    defResult.writeln("class $className {");
    List<FileSystemEntity> fileSystemEntities = FileHelpers.listFiles(folder);
    fileSystemEntities?.sort(FileHelpers.compare);

    for (FileSystemEntity fileSystemEntity in fileSystemEntities) {
      if (!FileHelpers.isDirectory(fileSystemEntity)) {
        defResult.write(
            "final ${FileHelpers.prepareFiledName(fileSystemEntity)} = ");
        defResult.writeln(
            "\" ${FileHelpers.getName(rootFolder)}/${FileHelpers.getName(folder)}/${FileHelpers.getName(fileSystemEntity)}\";");
      }
    }
    defResult.writeln("}");
    createdClass.add(className);
  }

  void _createFontsClass(List<String> fontNames) {
    if (fontNames.isNotEmpty) {
      String className = "_Fonts";
      defResult.writeln("class $className {");
      for (String fontName in fontNames) {
        defResult.writeln(
            "final ${StringHelpers.prepareName(fontName)} = $fontName;");
      }
      defResult.writeln("}");
      createdClass.add(className);
    }
  }

  void _createBaseClass() {
    defResult.writeln("class R {");
    for (String aClass in createdClass) {
      String fieldName = aClass + "Field";
      defResult.writeln("static $aClass $fieldName ;");
      defResult.writeln(
          "static $aClass get ${aClass.substring(1)} => $fieldName ?? ($fieldName = ${aClass}());");
    }
    defResult.writeln("}");
  }

  void _finishBuild() {
    desFile.writeAsString(defResult.toString());
  }
}

class Files {
  static File fromPath(String a) {
    File file = File(a);
    File b = File(file.parent.absolute.path);
    File c = File(b.parent.absolute.path);
    return File(c.parent.absolute.path + "\\$a");
  }
}

class Directories {
  static Directory fromPath(String a) {
    File file = File(a);
    File b = File(file.parent.absolute.path);
    File c = File(b.parent.absolute.path);
    return Directory(c.parent.absolute.path + "\\$a");
  }
}
