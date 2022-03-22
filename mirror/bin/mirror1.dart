import 'dart:async';
import 'dart:io';
import 'dart:mirrors';
import 'dart:typed_data';

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

  // var classMaps = {};
//   String classMapping = '''
// $librarysString
// class ClassMapFof {
//    static Map maps = {\n''';
//
//   var classBeanMaps = {};
//   String classBeanMapping = '''
// import \'bean_fof\';
// class ClassBeanFof {
//    static Map maps = {\n''';


  Map levelMaps = {};
  String levelMapping = '''
$librarysString
class ClassFof {
  static Map maps = ''';


  var separateMaps = {};
  String separateMapping = '''
$librarysString
class SeparateMapFof {
   static Map maps = {\n''';

  try {
    //循环类库
    librarys.forEach((element) {
      var elementReplace = element.replaceAll(':', '.');

      LibraryMirror libraryMirror =
      currentMirrorSystem().findLibrary(new Symbol(elementReplace));

      libraryMirror.declarations.forEach((key, value) async {
        var classOutMethod = {};
        if (value is ClassMirror) {
          // if (value.isAbstract) return;
          String name = MirrorSystem.getName(key);
          if (name.startsWith('_'))return;
          Map classInsMaps = {};
          try {
            var classInstanceMaps = {};
            String classMap =
            '''$librarysString
class ${name}Fof {
  static Map maps = {\n''';


            Map separateInsMaps = {};
            String separateInsMap =
            '''$librarysString
Map ${name}Map = {\n''';
            var constructorString ='   dynamic instance(String name,List<dynamic> positionalArguments){\n';
            var regularString ='   dynamic invoke(String name,List<dynamic> positionalArguments){\n';
            // for(int i = 0;i<value.declarations.length;i++) {
            value.declarations.forEach((key, declaration) {
              // dynamic key = value.declarations.keys.elementAt(i);
              // dynamic declaration = value.declarations.entries.elementAt(i);
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
                    factoryAllName = '$name.$factoryName';
                  } else {
                    factoryAllName = name;
                    factoryName = name;
                  }
                } else {
                  factoryAllName = name;
                  factoryName = name;
                }
                String paramsType = '';
                String paramsString = '';
                method.parameters.forEach((element) {
                  // print('element:${name1}')
                  if (element.isOptional) {
                  } else {
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
                  paramsString =
                      paramsString.substring(0, paramsString.length - 1);

                if (paramsType.length > 1 && paramsType.endsWith(','))
                  paramsType = paramsType.substring(0, paramsType.length - 1);
                // if(i==0)
                //实体类构造器
                constructorString +='if(name == \'$factoryName\'){\n';
                if (paramsString.isNotEmpty && paramsType.isNotEmpty) {
                  constructorString +='return Function.apply(($paramsType)=>$factoryAllName($paramsString), positionalArguments);\n';
                }else{
                  constructorString +='return Function.apply(()=>$factoryAllName(), positionalArguments);\n';
                }
                constructorString +='}\n';
                // classMapping += '}\n';
                // classMapping += '\'$name\':$name,\n';
                //构造实例存放映射
                // String methodName = MirrorSystem.getName(key);
                // classMaps['$methodName'] ='$methodName';
                // classMaps['$name'] = '$name';
                separateMaps['$name'] = '${name}Map';
                // dynamic function = (List<dynamic> positionalArgs) => value
                //     .newInstance(method.constructorName, positionalArgs)
                //     .reflectee;
                // Mapping.map[name] = function;
                // if(i==value.declarations.length-1)

                if (paramsString.isNotEmpty && paramsType.isNotEmpty) {
                  classInsMaps['$factoryName']= '($paramsType)=>$factoryAllName($paramsString)';
                  classInstanceMaps[factoryName] = '($paramsType)=>$factoryAllName($paramsString)';
                  separateInsMaps[factoryName] = '($paramsType)=>$factoryAllName($paramsString)';
                }else{
                  classInsMaps['$factoryName'] = '()=>$factoryAllName()';
                  classInstanceMaps[factoryName] = '()=>$factoryAllName()';
                  separateInsMaps[factoryName] = '()=>$factoryAllName()';
                  // classMap +='return Function.apply(()=>$factoryAllName(), positionalArguments);\n';
                }
              }else if(method.isStatic){
                //静态方法
                var staticName = MirrorSystem.getName(method.simpleName);
                constructorString +='if(name == \'$staticName\'){\n';

                String paramsType = '';
                String paramsString = '';
                method.parameters.forEach((element) {
                  // print('element:${name1}')
                  if (element.isOptional) {
                  } else {
                    String name1 = MirrorSystem.getName(element.simpleName);
                    String nameType = MirrorSystem.getName(element.type.simpleName);
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
                  paramsString =
                      paramsString.substring(0, paramsString.length - 1);

                if (paramsType.length > 1 && paramsType.endsWith(','))
                  paramsType = paramsType.substring(0, paramsType.length - 1);

                if (paramsString.isNotEmpty && paramsType.isNotEmpty) {
                  classInsMaps[staticName] = '($paramsType)=>$staticName($paramsString)';
                  classInstanceMaps[staticName] = '($paramsType)=>$staticName($paramsString)';
                  separateInsMaps[staticName] = '($paramsType)=>$staticName($paramsString)';
                  constructorString +='return Function.apply(($paramsType)=>$staticName($paramsString), positionalArguments);\n';
                }else{
                  if(method.isSynthetic){
                    classInsMaps[staticName] = '()=>$staticName';
                    classInstanceMaps[staticName] = '()=>$staticName';
                    separateInsMaps[staticName] = '()=>$staticName';
                    constructorString +='return Function.apply(()=>$staticName, positionalArguments);\n';
                  }else {
                    classInsMaps[staticName] = '()=>$staticName()';
                    classInstanceMaps[staticName] = '()=>$staticName()';
                    separateInsMaps[staticName] = '()=>$staticName()';
                    constructorString += 'return Function.apply(()=>$staticName(), positionalArguments);\n';
                  }
                }
                constructorString +='}\n';
              } else if(method.isRegularMethod){
                //实体方法
                // String methodName = MirrorSystem.getName(key);
                // classOutMethod[methodName] = method;

                var staticName = MirrorSystem.getName(method.simpleName);
                regularString +='if(name == \'$staticName\'){\n';

                String paramsType = '';
                String paramsString = '';
                method.parameters.forEach((element) {
                  // print('element:${name1}')
                  if (!element.isOptional) {
                    String name1 = MirrorSystem.getName(element.simpleName);
                    String nameType = MirrorSystem.getName(element.type.simpleName);
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
                  paramsString =
                      paramsString.substring(0, paramsString.length - 1);

                if (paramsType.length > 1 && paramsType.endsWith(','))
                  paramsType = paramsType.substring(0, paramsType.length - 1);

                if (paramsString.isNotEmpty && paramsType.isNotEmpty) {
                  classInsMaps[staticName] = '(${name} ${name.toLowerCase()},$paramsType)=>${name.toLowerCase()}.$staticName($paramsString)';
                  classInstanceMaps[staticName] = '(${name} ${name.toLowerCase()},$paramsType)=>${name.toLowerCase()}.$staticName($paramsString)';
                  separateInsMaps[staticName] = '(${name} ${name.toLowerCase()},$paramsType)=>${name.toLowerCase()}.$staticName($paramsString)';
                  regularString +='return Function.apply(($paramsType)=>${name.toLowerCase()}.$staticName($paramsString), positionalArguments);\n';
                }else{
                  if(method.isSynthetic){
                    classInsMaps[staticName] = '(${name} ${name.toLowerCase()})=>${name.toLowerCase()}.$staticName';
                    classInstanceMaps[staticName] = '(${name} ${name.toLowerCase()})=>${name.toLowerCase()}.$staticName';
                    separateInsMaps[staticName] = '(${name} ${name.toLowerCase()})=>${name.toLowerCase()}.$staticName';
                    regularString +='return Function.apply(()=>${name.toLowerCase()}.$staticName, positionalArguments);\n';
                  }else {
                    classInsMaps[staticName] ='(${name} ${name.toLowerCase()})=>${name.toLowerCase()}.$staticName()';
                    classInstanceMaps[staticName] = '(${name} ${name.toLowerCase()})=>${name.toLowerCase()}.$staticName()';
                    separateInsMaps[staticName] = '(${name} ${name.toLowerCase()})=>${name.toLowerCase()}.$staticName()';
                    regularString +=
                    'return Function.apply(()=>${name.toLowerCase()}.$staticName(), positionalArguments);\n';
                  }
                }
                regularString +='}\n';
              }
            });

            // classMaps['$name'] = classInsMaps;

            constructorString +='}\n';
            regularString +='}\n';

            //创建类的映射
            String temp = '';
            await classInstanceMaps.forEach((key, value){
              temp += '\'$key\':$value,\n';
            });

            // temp = temp.substring(0,classMapping.length-2);
            classMap += temp;
            classMap += '};\n';
            classMap += '}';
            // classMap+=constructorString;
            // classMap+=regularString;

            // var ff = Directory('bin/bean');
            // if (!ff.existsSync()) {
            //   await ff.create();
            // } else {
            //   await ff.delete(recursive: true);
            //   await ff.create();
            // }
            // //实际类的创建
            // File file = File('bin/bean/${name}Fof.dart');
            // classBeanMaps['$name'] = '${name}Fof';
            // if (!await file.existsSync()) {
            //   await file.create();
            // } else {
            //   await file.delete(recursive: true);
            //   await file.create();
            // }
            // await file.writeAsString(classMap);



            //创建类Mapping的映射
            String tempMap = '';
            await separateInsMaps.forEach((key, value){
              tempMap += '\'$key\':$value,\n';
            });

            // temp = temp.substring(0,classMapping.length-2);
            separateInsMap += tempMap;
            separateInsMap += '};';
            var fff = Directory('bin/separate');
            if (!fff.existsSync()) {
              await fff.create();
            } else {
              await fff.delete(recursive: true);
              await fff.create();
            }

            separateFile(name,separateInsMap);
          } catch (e) {}

          levelMaps['$name'] = classInsMaps;
        }
      });
    });



    //创建类的映射
    // String temp = '';
    // await classMaps.forEach((key, value){
    //   temp += '\'$key\':$value,\n';
    // });
    // // temp = temp.substring(0,classMapping.length-2);
    // classMapping += temp;
    // classMapping += '};\n';
    // classMapping += '}';

    // File file1 = File('bin/class_mapping.dart');
    // if (!await file1.existsSync()) {
    //   await file1.create();
    // } else {
    //   await file1.delete(recursive: true);
    //   await file1.create();
    // }
    // await file1.writeAsString(classMapping);



    //创建类maping的映射
    String tempSe = '';
    await separateMaps.forEach((key, value){
      tempSe += '\'$key\':$value,\n';
    });
    // temp = temp.substring(0,classMapping.length-2);
    separateMapping += tempSe;
    separateMapping += '};\n';
    separateMapping += '}';

    File fileSe = File('bin/separete_mapping.dart');
    if (!await fileSe.existsSync()) {
      await fileSe.create();
    } else {
      await fileSe.delete(recursive: true);
      await fileSe.create();
    }
    await fileSe.writeAsString(separateMapping);


    //bean类的映射
    String temp1 = '';
    // await classBeanMaps.forEach((key, value){
    //   temp1 += '\'$key\':$value,\n';
    // });
    //
    // classBeanMapping += temp1;
    // classBeanMapping += '};\n';
    // classBeanMapping += '}';

    // File fileBean = File('bin/class_bean.dart');
    // if (!await fileBean.existsSync()) {
    //   await fileBean.create();
    // } else {
    //   await fileBean.delete(recursive: true);
    //   await fileBean.create();
    // }
    // await fileBean.writeAsString(classBeanMapping);




    String tempLevel = '{\n';
    await levelMaps.forEach((key, value) {
      tempLevel +='\'$key\':';
      var classInsTemp = '{\n';
      value = value as Map;
      value.forEach((key, value) {
        classInsTemp += '\'$key\':$value,\n';
      });
      classInsTemp += '},\n';
      tempLevel += classInsTemp;
    });

    // temp = temp.substring(0,classMapping.length-2);
    levelMapping += tempLevel;
    levelMapping += '};\n';
    levelMapping += '}';
    //创建类的映射
    File file = File('bin/level_mapping.dart');
    if (!await file.existsSync()) {
      await file.create();
    }
    await file.writeAsString(levelMapping);
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
  } catch (e) {
    print(e);
  }

  // dynamic fff = Function.apply((String name,int age1) => Animal(name,age:age1), ['dd',22]);
  // print(fff.name);
  // print(fff.age);
}

separateFile(String name,String separateInsMap) async{
  //实际类映射的创建
  File fileMap = File('bin/separate/${name}Fof.dart');
  // classBeanMaps['$name'] = '${name}Fof';
  if (await !fileMap.existsSync()) {
    await fileMap.create();
  } else {
    await fileMap.delete(recursive: true);
    await fileMap.create();
  }
  await fileMap.writeAsString(separateInsMap);
}
// class Animal {
//   String name = '2332';
//   int age = 324;
//
//   Animal(this.name, {this.age});
//
//   void dfd({int qqq}) {}
// }
