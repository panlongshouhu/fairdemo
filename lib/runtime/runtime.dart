import 'package:flutter/material.dart';

import 'orm/class_convert.dart';

class Runtime {
  /**
   * className转对象
   */
  static Future<dynamic> convertClass(String className) {
    if (className.isEmpty) {
      return null;
    }

    return ClassMapping.getClass(className);
  }

  /**
   * methodName转方法
   */
  static Object convertMethod(Object instance, String methodName) {
    if (instance == null || methodName.isEmpty) {
      return null;
    }

    return null;
  }
}
