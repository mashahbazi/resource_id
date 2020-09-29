class Utils {
  static List<String> yamlMapToListString(dynamic list) {
    if (list is List<dynamic> && list != null) {
      return List<String>.from(list.map((item) {
        return item.toString();
      }));
    } else {
      return [];
    }
  }
}
