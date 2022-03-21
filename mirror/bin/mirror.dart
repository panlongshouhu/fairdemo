import 'dart:async';
import 'dart:io';
import 'dart:mirrors';
import 'dart:typed_data';
import 'mapping.dart';

void main(List<String> arguments) async {
  var librarys = [
    'dart:async',
    'dart:collection',
    'dart:convert',
    'dart:core',
    'dart:developer',
    'dart:math',
    'dart:typed_data',
    'dart:ffi',
    'dart:io',
    'dart:isolate'
  ];

  var librarysString = '';
  librarys.forEach((element) {
    librarysString += 'import \'$element\'\;\n';
  });

  Map classMaps = {};
  String classMapping = '''
$librarysString
class ClassMap {
  static Map maps = {\n''';
  try {
    //循环类库
    librarys.forEach((element) async {
      element = element.replaceAll(':', '.');

      LibraryMirror libraryMirror =
          currentMirrorSystem().findLibrary(new Symbol(element));

      libraryMirror.declarations.forEach((key, value) async {
        var classOutMethod = {};
        if (value is ClassMirror) {
          // if (value.isAbstract) return;
          String name = MirrorSystem.getName(key);
          if (!name.startsWith('_')) {
            value.declarations.forEach((key, declaration) async {
              MethodMirror method;
              if (declaration is MethodMirror) method = declaration;
              if (method == null) return;
              if (method.isConstructor) {
                //工厂构造
                var factoryName = '';
                if (method.isFactoryConstructor) {
                  factoryName = MirrorSystem.getName(method.constructorName);
                  if (factoryName.isNotEmpty) {
                    factoryName = '$name.$factoryName';
                  } else {
                    factoryName = name;
                  }
                } else {
                  factoryName = name;
                }
                String paramsType = '';
                String paramsString = '';
                method.parameters.forEach((element) {
                  // print('element:${name1}')
                  if (element.isOptional) {
                  } else {
                    // String name1 = MirrorSystem.getName(element.simpleName);
                    // String nameType =
                    //     MirrorSystem.getName(element.type.simpleName);
                    // if (name1.startsWith('_')) {
                    //   paramsString = '';
                    //   paramsType = '';
                    //   return;
                    // }
                    // paramsType += '${nameType} ${name1},';
                    // paramsString += '${name1},';
                    // isNoparameter = true;
                    // mustArgs.add(element.defaultValue);
                  }
                });
                // if (paramsString.length > 1 && paramsString.endsWith(','))
                //   paramsString =
                //       paramsString.substring(0, paramsString.length - 1);
                //
                // if (paramsType.length > 1 && paramsType.endsWith(','))
                //   paramsType = paramsType.substring(0, paramsType.length - 1);
                // classMapping += 'if(name == \'$name\'){\n';
                // if (paramsString.isNotEmpty && paramsType.isNotEmpty) {
                //
                //   classMapping +=
                //   'return ($paramsType)=>$factoryName($paramsString);\n';
                //
                // }else{
                //   classMapping +=
                //   'return ()=>$factoryName();\n';
                //
                // }
                // classMapping += '}\n';
                // classMapping += '\'$name\':$name,\n';
                classMaps['$name'] = '$name';
                dynamic function = (List<dynamic> positionalArgs) => value
                    .newInstance(method.constructorName, positionalArgs)
                    .reflectee;
                Mapping.map[name] = function;
              } else {
                String methodName = MirrorSystem.getName(key);
                classOutMethod[methodName] = method;
              }
            });

            //方法输出
            try {
              var ff = Directory('bin/bean');
              if (!ff.existsSync()) {
                await ff.create();
              } else {
                await ff.delete(recursive: true);
                await ff.create();
              }
              //实际类的创建
              File file = File('bin/bean/${name}Ex.dart');
              if (!await file.existsSync()) {
                await file.create();
              }
              String classMap =
                  '''extension ${name}Ex on $name {\n
                  static dynamic invoke(String name,[dynamic params]){
              if(name.isEmpty)return;\n''';
              classOutMethod.forEach((key, value) async {
                // var value1 = MirrorSystem.getName(key);
                classMap += 'if(name.endsWith(\'$key\')){\n';
                var valueString = value
                    .toString()
                    .replaceAll('MethodMirror on ', '')
                    .replaceAll('\'', '');
                classMap += 'return ${valueString}();';
                classMap += '\n}\n';
              });
              classMap += 'return null;\n';
              classMap += '}\n';
              classMap += '}';
              await file.writeAsString(classMap);
            } catch (e) {}
          }
        }
      });
    });

    String temp = '';
    await classMaps.forEach((key, value) {
      temp += '\'$key\':$value,\n';
    });

    // temp = temp.substring(0,classMapping.length-2);
    classMapping += temp;
    classMapping += '};\n';
    classMapping += '}';
    //创建类的映射
    File file = File('bin/class_mapping.dart');
    if (!await file.existsSync()) {
      await file.create();
    }
    await file.writeAsString(classMapping);
    // String test = 'Utf8Codec';
    // String test = 'File';
    // var df = Uint8List(2);
    // String test = 'ZLibCodec';
    // String test = 'JsonUnsupportedObjectError';
    // dynamic fun = Function.apply(Mapping.map[test], [
    //   [df]
    // ]);
    // print(fun.toString());
    //实际类的创建
  //   File file1 = File('bin/map.json');
  //
  //   String classMap = '[\n';
  //   Mapping.map.forEach((key, value) {
  //     String valueString = value.toString().replaceAll("Closure: ", "");
  //     classMap += '{\n\"key\":\"$key\",\n\"value\":\"$valueString\"\n},\n';
  //   });
  //   classMap = classMap.substring(0, classMap.length - 2);
  //   classMap += '\n]';
  //   await file1.writeAsString(classMap);
  // } catch (e) {
  //   print(e);
  // }

  // dynamic fff = Function.apply((String name,int age1) => Animal(name,age:age1), ['dd',22]);
  // print(fff.name);
  // print(fff.age);
}

// class Animal {
//   String name = '2332';
//   int age = 324;
//
//   Animal(this.name, {this.age});
//
//   void dfd({int qqq}) {}
// }
