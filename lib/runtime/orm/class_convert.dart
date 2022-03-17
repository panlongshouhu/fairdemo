import 'dart:io';

import 'package:demo0314/runtime/config/api.dart';
import 'package:args/args.dart';
import 'package:flutter/material.dart';
class ClassMapping {
  static Future<dynamic> getClass(String className) async {
    if(className.endsWith('Text')){
      return Function.apply(() => Padding,[{'data':'nihao'}],null);
    }

    var frameworkAPI = Api.frameworkAPI;

    var includedPaths = <String>[];
    for (var dirPath in frameworkAPI) {

      var dir = Directory('$dirPath');
      if (!await dir.exists()) continue;
      var files = await dir
          .list(recursive: true)
          .map((element) => element.absolute.path)
          .where((event) => event.endsWith('.dart'))
          .toList();
      includedPaths.addAll(files);
    }

    includedPaths.forEach((element) {
      print(element);
    });

    return Function.apply(() => className, null);
  }
}
