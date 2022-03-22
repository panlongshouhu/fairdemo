import 'dart:math';
import 'dart:mirrors';
import 'NumberParsing.dart';
import 'sdk/fof_mapping.dart';

void main(List<String> arguments) async {
  LibraryMirror libraryMirror =
  currentMirrorSystem().findLibrary(new Symbol('dart.convert'));

  libraryMirror.declarations.forEach((key, value) async {
    if (value is ClassMirror) {
      String name = MirrorSystem.getName(key);
      if (!name.startsWith('_')) {
        value.declarations.forEach((key, declaration) {
          MethodMirror method;
          if (declaration is MethodMirror) method = declaration;
          if (method != null && method.isConstructor) {
            dynamic function = (List<dynamic> positionalArgs) =>value.newInstance(method.constructorName, positionalArgs,{Symbol('llowInvalid'):true}).reflectee;
            SeparateMapFof.maps[name] = function;
          }
        });
      }
    }
  });
  // String test = 'Utf8Codec';
  // String test = 'LineSplitter';
  String test = 'Latin1Codec';
  // String test = 'AsciiCodec';
  // String test = 'JsonUnsupportedObjectError';
  dynamic fun = Function.apply(SeparateMapFof.maps[test], [[]]);
  print(fun.toString());
  // dynamic fff = Function.apply((String name,int age1) => Animal(name,age:age1), ['dd',22]);
  // print(fff.name);
  // print(fff.age);
  Random random = Random();
  print(random.parseInt1()); // Use an extension method.
}

class Animal {
  String name = '2332';
  int age = 324;
  Animal(this.name, {this.age});
}


