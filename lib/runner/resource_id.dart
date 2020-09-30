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
    _start();
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

  void _createAssets(String asset) {
    File file = Files.fromPath(asset);
    if (!file.existsSync()) {
      print("File or folder with directory " + asset + " doesn't exist");
      return;
    }
    if (!FileHelpers.isDirectory(file)) {
      print("path " + asset + " is file which is not support yet");
      return;
    }
    String assetParent =
        StringHelpers.replaceLast(asset, "/" + FileHelpers.getName(file), "");
    File parentFile = Files.fromPath(assetParent);
    _createDefaultRes(parentFile, file);
  }

  void _start() {
    bool createResult = _createBuildFile();
    if (!createResult) return;
    File rootFile = Files.fromPath("assets");
    List<File> files = FileHelpers.listFiles(rootFile);
    if (files == null) {
      print("there is not assets folder");
      return;
    }
    files.sort(FileHelpers.compare);
    for (File file in files) {
      if (FileHelpers.isDirectory(file)) {
        _checkFolders(rootFile, file);
      }
    }
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

  void _checkFolders(File rootFile, File folder) {
    _createDefaultRes(rootFile, folder);
//    if (folder.name == "translations") _generateTranslation(folder);
  }

  // TODO : add translations
//  void _generateTranslation(File folder) {
//    File jsonFile = null;
//    for (File file in folder.listFiles() ?? []) {
//      if (file.name.substring(file.name.lastIndexOf(".")) == ".json") {
//        jsonFile = file;
//        break;
//      }
//    }
//    if (jsonFile == null) return;
//    try {
//      String bufferedReader = "";
//      String stringBuilder =  StringBuilder();
//      bufferedReader.lines().forEach(stringBuilder::append);
//      bufferedReader.close();
//      String jsonStr = stringBuilder.toString();
//      try {
//        Map<String, String> pairs =  Gson().fromJson(jsonStr, Map.class);
//        String className = "_Strings";
//        createdClass.add(className);
//        bufferedWriter
//            ;append("class ")
//            ;append(className)
//            ;append(" {\n");
//        for (String s : pairs.keySet()) {
//    if (prepareStringFieldNames(s).equals("Something_unexpected_happened_Try_restarting_the_app_"))
//    print(s);
//    bufferedWriter
//        ;append("     final ")
//        ;append(prepareStringFieldNames(s))
//        ;append(" = \"");
//    if (s.contains("\n")) {
//    int indexOfBreak = s.indexOf("\n");
//    bufferedWriter
//        ;append(s.substring(0, indexOfBreak))
//        ;append("\"+");
//    bufferedWriter
//        ;append("\"\\n\"+");
//    bufferedWriter
//        ;append("\"")
//        ;append(s.substring(indexOfBreak + 1));
//    } else {
//    bufferedWriter
//        ;append(s);
//    }
//    bufferedWriter
//        ;append("\" ;\n");
//    }
//    bufferedWriter
//        ;append("}\n");
//    } catch (JsonSyntaxException s) {
//    s.printStackTrace();
//    }
//    } catch (IOException e) {
//    e.printStackTrace();
//    }
//  }//  prepareStringFieldNames(String name) {
//    name = name.replaceAll("[^A-Za-z0-9]", "_");
//    while (Character.isDigit(name.charAt(0)))
//      name = name.substring(1);
//    return name;
//  }

  void _createDefaultRes(File rootFile, File folder) {
    String className = "_" + FileHelpers.getClassNameFromFolder(folder);
    defResult.writeln("class $className {");
    List<File> files = FileHelpers.listFiles(folder);
    if (files != null) {
      files.sort(FileHelpers.compare);
      for (File file in files) {
        if (!FileHelpers.isDirectory(file)) {
          defResult
              .write("final ${FileHelpers.prepareFiledName(file: file)} = ");
          defResult.writeln(
              "\" ${FileHelpers.getName(rootFile)}/${FileHelpers.getName(folder)}/${FileHelpers.getName(file)}\";");
        }
      }
    }
    defResult.writeln("}");
    createdClass.add(className);
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
