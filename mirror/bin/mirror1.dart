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
class ClassFof {
  static Map maps = ''';
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
            Map classInsMaps = {};

            value.declarations.forEach((key, declaration) async {
              MethodMirror method;
              if (declaration is MethodMirror) method = declaration;
              if (method == null) return;
              if (method.isConstructor) {
                //工厂构造
                var factoryName = '';
                var factoryAllName = '';
                if (method.isFactoryConstructor) {
                  factoryName = MirrorSystem.getName(method.constructorName);
                  if (factoryName.isNotEmpty) {
                    factoryName = '$factoryName';
                    factoryAllName = '$name.$factoryName';
                  } else {
                    factoryName = name;
                    factoryAllName = name;
                  }
                } else {
                  factoryName = name;
                  factoryAllName = name;
                }
                String paramsType = '';
                String paramsString = '';
                method.parameters.forEach((element) {
                  // print('element:${name1}')
                  if (!element.isOptional) {
                    String name1 = MirrorSystem.getName(element.simpleName);
                    String nameType =
                        MirrorSystem.getName(element.type.simpleName);
                    if (name1.startsWith('_')) {
                      paramsString = '';
                      paramsType = '';
                      return;
                    }
                    paramsType += '${nameType} ${name1},';
                    paramsString += '${name1},';
                  }
                });
                if (paramsString.length > 1 && paramsString.endsWith(','))
                  paramsString = paramsString.substring(0, paramsString.length - 1);

                if (paramsType.length > 1 && paramsType.endsWith(','))
                  paramsType = paramsType.substring(0, paramsType.length - 1);
                if (paramsString.isNotEmpty && paramsType.isNotEmpty) {
                  classInsMaps['$factoryName']= '($paramsType)=>$factoryAllName($paramsString)';
                }else{
                  if(method.isConstructor) {
                    classInsMaps['$factoryName'] = '()=>$factoryAllName()';
                  }else{
                    classInsMaps['$factoryName'] = '()=>$factoryAllName';
                  }
                }
                // classMapping += '}\n';
                // classMapping += '\'$name\':$name,\n';
                // classInsMaps['$name'] = '$name';
                // dynamic function = (List<dynamic> positionalArgs) => value
                //     .newInstance(method.constructorName, positionalArgs)
                //     .reflectee;
                // Mapping.map[name] = function;

              } else if(method.isStatic){

              }else {
                String methodName = MirrorSystem.getName(key);
                classOutMethod[methodName] = method;
              }
            });


            classMaps['$name'] = classInsMaps;
          }
        }
      });
    });

    String temp = '{\n';
    await classMaps.forEach((key, value) {
      temp +='\'$key\':';
      var classInsTemp = '{\n';
      value = value as Map;
      value.forEach((key, value) {
        classInsTemp += '\'$key\':$value,\n';
      });
      classInsTemp += '},\n';
      temp += classInsTemp;
    });

    // temp = temp.substring(0,classMapping.length-2);
    classMapping += temp;
    classMapping += '};\n';
    classMapping += '}';
    //创建类的映射
    File file = File('bin/bean_mapping.dart');
    if (!await file.existsSync()) {
      await file.create();
    }
    await file.writeAsString(classMapping);
  } catch (e) {
    print(e);
  }

}
