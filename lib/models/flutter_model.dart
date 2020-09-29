import 'package:resource_id/helpers/Utils.dart';
import 'package:yaml/yaml.dart';
import 'package:resource_id/models/font_model.dart';

class FlutterModel {
  final List<String> assets;
  final List<FontModel> fonts;

  FlutterModel.fromYamlMap(YamlMap yamlMap)
      : this.assets = Utils.yamlMapToListString(yamlMap["flutter"]["assets"]),
        this.fonts = toListFonts(yamlMap["flutter"]["fonts"]);
}

List<FontModel> toListFonts(dynamic list) {
  if (list is List<dynamic> && list != null) {
    return List<FontModel>.from(list.map((yamlMap) {
      return FontModel.fromYamlMap(yamlMap);
    }));
  } else {
    return [];
  }
}
