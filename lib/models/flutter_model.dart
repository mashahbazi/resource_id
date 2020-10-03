import 'package:resource_id/helpers/Utils.dart';
import 'package:yaml/yaml.dart';

class FlutterModel {
  final List<String> assets;
  final List<String> fonts;

  static List<String> toListFonts(dynamic list) {
    if (list is List<dynamic> && list != null) {
      return List<String>.from(list.map((yamlMap) => yamlMap["family"]));
    } else {
      return [];
    }
  }

  FlutterModel.fromYamlMap(YamlMap yamlMap)
      : this.assets = Utils.yamlMapToListString(yamlMap["flutter"]["assets"]),
        this.fonts = toListFonts(yamlMap["flutter"]["fonts"]);
}
