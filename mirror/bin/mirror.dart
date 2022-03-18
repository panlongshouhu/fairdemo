import 'dart:convert';
import 'dart:math';
import 'dart:mirrors';

import 'mapping.dart';

void main(List<String> arguments) async {
  // InstanceMirror classMirror = reflect(() =>
  //     Random()) as InstanceMirror; //类名即是Type
  // print(classMirror.reflectee.runtimeType);
  // Random random = Random();
  // print(random.runtimeType);

  // ClassMirror c = reflectClass('Random');
  // InstanceMirror im = c.newInstance(const Symbol(''), ['MyAttributeValue']);
  // var o = im.reflectee;

  LibraryMirror libraryMirror =
  currentMirrorSystem().findLibrary(new Symbol('dart.convert'));

  libraryMirror.declarations.forEach((key, value) async {
    // print(value.toString());
    // DeclarationMirror classMirror = value;
    if (value is ClassMirror) {
      String name = MirrorSystem.getName(key);
      if (!name.startsWith('_')) {
        // value.declarations.forEach((symbol, declarationMirror) {
        //   // print(MirrorSystem.getName(symbol));
        // });

        // This doesn't show me the constructor
        // print("+ Members");
        // value.instanceMembers.forEach((symbol, methodMirror) {
        //   print(MirrorSystem.getName(symbol));
        // });
        // value.metadata.forEach((element) {
        //   element.
        // });
        List<dynamic> positionalArguments = List();
        // value.metadata.forEach((element) {
        //   print(element.toString());
        // });

        Map<Symbol, dynamic> namedArguments = Map();
        List<dynamic> mustArgs = List();
        value.declarations.forEach((key, declaration) {
          MethodMirror method;
          if (declaration is MethodMirror) method = declaration;

          if (method != null && method.isConstructor) {
            // print('simpleName: ${method.simpleName}');
            // print('method: ${method.constructorName}');
            // print('parameters: ${method.parameters}');
            bool isNoparameter = true;
            int optionalNum = 0;
            // method.parameters.forEach((element) {
            //   // print('element:${element}');
            //   if (element.isOptional) {
            //     // print('element:${element}');
            //     isNoparameter = false;
            //     positionalArguments.add(element.defaultValue);
            //     optionalNum++;
            //   } else {
            //     isNoparameter = true;
            //     mustArgs.add(element.defaultValue);
            //   }
            // });
            //  function;
            // if (method.parameters.isEmpty ||
            //     method.parameters.length - optionalNum <= 0) {
            dynamic function = (List<dynamic> positionalArgs) =>value.newInstance(method.constructorName, positionalArgs).reflectee;
            // return value.runtimeType;
            // value.newInstance(method.constructorName, []).reflectee;
            //   return ;
            // };
            // } else {
            //   function = (positionalArguments) {
            //     // print(positionalArguments.toString());
            //     // if (positionalArguments != null &&
            //     //     positionalArguments.isNotEmpty) {
            //     //   mustArgs = positionalArguments;
            //     // }
            //     return value
            //         .newInstance(method.constructorName, positionalArguments)
            //         .reflectee;
            //   };
            // }
            Mapping.map[name] = function;
          }
        });
        // dynamic dd = ;

        // var instance = value.newInstance(Symbol.empty, []);
        // print(instance);
        // value.instanceMembers.forEach((key, value) {
        //   print(value.constructorName);
        // });
      }
    }
  });
  // String test = 'Utf8Codec';
  // String test = 'LineSplitter';
  String test = 'AsciiCodec';
  // String test = 'JsonUnsupportedObjectError';
  dynamic fun = Function.apply(Mapping.map[test], [[]]);
  print(fun.toString());
  // dynamic fff = Function.apply((String name,int age1) => Animal(name,age:age1), ['dd',22]);
  // print(fff.name);
  // print(fff.age);
}

class Animal {
  String name = '2332';
  int age = 324;

  Animal(this.name, {this.age});
}
