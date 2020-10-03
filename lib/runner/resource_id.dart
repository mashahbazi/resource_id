import 'dart:io';

import 'package:resource_id/helpers/file_helpers.dart';
import 'package:resource_id/helpers/string_helpers.dart';
import 'package:resource_id/models/flutter_model.dart';
import 'package:yaml/yaml.dart';

class ResourceId {
  static void run() {
    ResourceId resourceId = ResourceId();
    resourceId._run();
  }

  void _run() {
    FlutterModel flutterModel = _readPubspecFile();
    _start(flutterModel);
  }

  FlutterModel _readPubspecFile() {
    File pubspec = File("pubspec.yaml");
    String yaml = pubspec.readAsStringSync();
    YamlMap yamlMap = loadYaml(yaml);
    return FlutterModel.fromYamlMap(yamlMap);
  }

  final List<String> createdClass = [];
  final List<String> singleFilesPath = [];
  final List<String> reservedFolderNameForIgnore =
      List.unmodifiable(["2.0x", "3.0x"]);

  File desFile;
  StringBuffer desResult;

  void _start(FlutterModel flutterModel) {
    bool createResult = _createBuildFile();
    if (!createResult) return;

    for (String filePath in flutterModel.assets) {
      _createAssets(filePath);
    }
    _createFontsClass(flutterModel.fonts);
    _createSingleFiles(singleFilesPath);
    _createBaseClass();
    _finishBuild();
  }

  bool _createBuildFile() {
    Directory lib = Directory("lib");
    if (!lib.existsSync()) {
      lib.createSync();
    }
    Directory build = Directory("lib/build");
    if (!build.existsSync()) {
      build.createSync();
    }
    desFile = File("lib/build/build.dart");
    if (desFile.existsSync()) {
      desFile.delete();
    }
    try {
      desFile.createSync();
      desResult = new StringBuffer(
          "// ignore_for_file: non_constant_identifier_names\n");
    } catch (e) {
      String errorMessage = "BUILDER ERROR:Can't create build file\n";
      if (e is FileSystemException) {
        errorMessage += e.message;
      }
      print(errorMessage);
      return false;
    }
    return true;
  }

  void _createAssets(String assetPath) {
    Directory folder = Directory(assetPath);
    if (!folder.existsSync()) {
      File file = File(assetPath);
      if (!FileHelpers.isDirectory(file)) {
        singleFilesPath.add(assetPath);
      } else {
        print("File or folder with directory " + assetPath + " doesn't exist");
      }
      return;
    }
    _createDefaultRes(folder.parent, folder);
  }

  void _createDefaultRes(Directory rootFolder, Directory folder) {
    String className = "_" + FileHelpers.getClassNameFromFolder(folder);
    desResult.writeln("class $className {");
    List<FileSystemEntity> fileSystemEntities = FileHelpers.listFiles(folder);
    fileSystemEntities?.sort(FileHelpers.compare);

    for (FileSystemEntity fileSystemEntity in fileSystemEntities) {
      if (!FileHelpers.isDirectory(fileSystemEntity)) {
        desResult.writeln(
            FileHelpers.getSrcLineOfFileSystem(fileSystemEntity, folder.path));
      }
    }
    desResult.writeln("}");
    createdClass.add(className);
  }

  void _createFontsClass(List<String> fontNames) {
    if (fontNames.isNotEmpty) {
      String className = "_Fonts";
      desResult.writeln("class $className {");
      for (String fontName in fontNames) {
        desResult.writeln(
            "final String ${StringHelpers.prepareName(fontName)} = \"$fontName\";");
      }
      desResult.writeln("}");
      createdClass.add(className);
    }
  }

  void _createSingleFiles(List<String> singleFilesPath) {
    if (singleFilesPath.isNotEmpty) {
      String className = "_SingleFile";
      desResult.writeln("class $className {");
      for (String singleFile in singleFilesPath) {
        desResult.writeln(
            "final String ${FileHelpers.getName(File(singleFile))} = \"$singleFile\";");
      }
      desResult.writeln("}");
      createdClass.add(className);
    }
  }

  void _createBaseClass() {
    desResult.writeln("class R {");
    for (String aClass in createdClass) {
      String fieldName = aClass + "Field";
      desResult.writeln("static $aClass $fieldName ;");
      desResult.writeln(
          "static $aClass get ${aClass.substring(1)} => $fieldName ?? ($fieldName = ${aClass}());");
    }
    desResult.writeln("}");
  }

  void _finishBuild() {
    desFile.writeAsString(desResult.toString());
  }
}
