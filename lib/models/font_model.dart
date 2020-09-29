import 'package:yaml/yaml.dart';

class FontModel {
  final String family;
  final List<FontAssetModel> fonts;

  FontModel.fromYamlMap(YamlMap yamlMap)
      : this.family = yamlMap["family"],
        this.fonts = toListFontAssetModel(yamlMap["fonts"]);
}

class FontAssetModel {
  final String asset;

  FontAssetModel.fromYamlMap(YamlMap yamlMap) : this.asset = yamlMap["asset"];
}

List<FontAssetModel> toListFontAssetModel(dynamic list) {
  if (list is List<dynamic> && list != null) {
    return List<FontAssetModel>.from(list.map((yamlMap) {
      return FontAssetModel.fromYamlMap(yamlMap);
    }));
  } else {
    return [];
  }
}
