import 'dart:async';
import 'dart:core';

import 'package:build/build.dart';
import 'package:resource_id/runner/resource_id.dart';

Builder resourceId(BuilderOptions options) {
  return ResourceIdBuilder();
}

class ResourceIdBuilder extends Builder {
  @override
  FutureOr<Function> build(BuildStep buildStep) async {
    ResourceId.run();
    return null;
  }

  @override
  Map<String, List<String>> get buildExtensions {
    return {
      "main.dart": [
        ".",
      ]
    };
  }
}
