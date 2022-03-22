import 'dart:io';
import 'dart:mirrors';
RegExp mobile = new RegExp(r"[0-9A-Za-z]");
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

  var separateMaps = {};
  String separateMapping = '''
$librarysString
import \'sdk/fof_system.dart\';
class FofMapping {
   static Map maps = {\n''';

  var wxAllMaps = {};
  String wxAll = '''
library wx.system;\n''';

  var num = 0;
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

            Map separateInsMaps = {};
            String separateInsMap =
            '''$librarysString
Map ${name}Map = {\n''';

            num++;
            value.declarations.forEach((key, declaration) {

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
                } else if(value.isAbstract){
                  return;
                }else{
                  factoryAllName = name;
                  factoryName = name;
                }
                String paramsType = '';
                String paramsString = '';
                bool isAnomaly = false;
                method.parameters.forEach((element) {
                  // print('element:${name1}')
                  if (element.isOptional) {
                  } else {
                    String name1 = MirrorSystem.getName(element.simpleName);
                    String nameType =
                        MirrorSystem.getName(element.type.simpleName);
                    // print(nameType);
                    if (name1.startsWith('_') ||
                        nameType=='T' ||
                        nameType == 'E' ||
                    nameType.contains('->')) {
                      paramsString = '';
                      paramsType = '';
                      isAnomaly = true;
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

                separateMaps['$name'] = '${name}Map';
                wxAllMaps['$name'] = '${name}Fof.dart';

                if(isAnomaly)return;
                if (paramsString.isNotEmpty && paramsType.isNotEmpty) {
                  classInsMaps['$factoryName']= '($paramsType)=>$factoryAllName($paramsString)';
                  classInstanceMaps[factoryName] = '($paramsType)=>$factoryAllName($paramsString)';
                  if(mobile.hasMatch(factoryName))
                  separateInsMaps[factoryName] = '($paramsType)=>$factoryAllName($paramsString)';
                }else{
                  classInsMaps['$factoryName'] = '()=>$factoryAllName()';
                  classInstanceMaps[factoryName] = '()=>$factoryAllName()';
                  if(mobile.hasMatch(factoryName))
                  separateInsMaps[factoryName] = '()=>$factoryAllName()';
                  // classMap +='return Function.apply(()=>$factoryAllName(), positionalArguments);\n';
                }
              }else if(method.isStatic){
                //静态方法
                var staticName = MirrorSystem.getName(method.simpleName);

                String paramsType = '';
                String paramsString = '';
                bool isAnomaly = false;
                method.parameters.forEach((element) {
                  // print('element:${name1}')
                  if (element.isOptional) {
                  } else {
                    String name1 = MirrorSystem.getName(element.simpleName);
                    String nameType = MirrorSystem.getName(element.type.simpleName);
                    if (name1.startsWith('_') ||
                        nameType=='T' ||
                        nameType == 'E' ||
                        nameType.contains('->')) {
                      paramsString = '';
                      paramsType = '';
                      isAnomaly = true;
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

                if(isAnomaly)return;
                if (paramsString.isNotEmpty && paramsType.isNotEmpty) {
                  classInsMaps[staticName] = '($paramsType)=>$name.$staticName($paramsString)';
                  classInstanceMaps[staticName] = '($paramsType)=>$name.$staticName($paramsString)';
                  if(mobile.hasMatch(staticName))
                  separateInsMaps[staticName] = '($paramsType)=>$name.$staticName($paramsString)';
                }else{
                  if(method.isSynthetic || method.isGetter){
                    classInsMaps[staticName] = '()=>$name.$staticName';
                    classInstanceMaps[staticName] = '()=>$name.$staticName';
                    if(mobile.hasMatch(staticName))
                    separateInsMaps[staticName] = '()=>$name.$staticName';
                  }else {
                    classInsMaps[staticName] = '()=>$name.$staticName()';
                    classInstanceMaps[staticName] = '()=>$name.$staticName()';
                    if(mobile.hasMatch(staticName))
                    separateInsMaps[staticName] = '()=>$name.$staticName()';
                  }
                }
              } else if(method.isRegularMethod){
                //实体方法
                // String methodName = MirrorSystem.getName(key);
                // classOutMethod[methodName] = method;

                var staticName = MirrorSystem.getName(method.simpleName);

                String paramsType = '';
                String paramsString = '';
                bool isAnomaly = false;
                method.parameters.forEach((element) {
                  // print('element:${name1}')
                  if (!element.isOptional) {
                    String name1 = MirrorSystem.getName(element.simpleName);
                    String nameType = MirrorSystem.getName(element.type.simpleName);
                    if (name1.startsWith('_' ) ||
                        nameType=='T' ||
                        nameType == 'E' ||
                        nameType.contains('->')) {
                      paramsString = '';
                      paramsType = '';
                      isAnomaly = true;
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

                if(isAnomaly)return;
                if (paramsString.isNotEmpty && paramsType.isNotEmpty) {
                  classInsMaps[staticName] = '(${name} ${name.toLowerCase()},$paramsType)=>${name.toLowerCase()}.$staticName($paramsString)';
                  classInstanceMaps[staticName] = '(${name} ${name.toLowerCase()},$paramsType)=>${name.toLowerCase()}.$staticName($paramsString)';
                  if(mobile.hasMatch(staticName))
                  separateInsMaps[staticName] = '(${name} ${name.toLowerCase()},$paramsType)=>${name.toLowerCase()}.$staticName($paramsString)';
                }else{
                  if(method.isSynthetic){
                    classInsMaps[staticName] = '(${name} ${name.toLowerCase()})=>${name.toLowerCase()}.$staticName';
                    classInstanceMaps[staticName] = '(${name} ${name.toLowerCase()})=>${name.toLowerCase()}.$staticName';
                    if(mobile.hasMatch(staticName))
                    separateInsMaps[staticName] = '(${name} ${name.toLowerCase()})=>${name.toLowerCase()}.$staticName';
                  }else {
                    classInsMaps[staticName] ='(${name} ${name.toLowerCase()})=>${name.toLowerCase()}.$staticName()';
                    classInstanceMaps[staticName] = '(${name} ${name.toLowerCase()})=>${name.toLowerCase()}.$staticName()';
                    if(mobile.hasMatch(staticName))
                    separateInsMaps[staticName] = '(${name} ${name.toLowerCase()})=>${name.toLowerCase()}.$staticName()';
                  }
                }
              }
            });

            //创建类Mapping的映射
            String tempMap = '';
            await separateInsMaps.forEach((key, value){
              tempMap += '\'$key\':$value,\n';
            });
            separateInsMap += tempMap;
            separateInsMap += '};';
            // var fff = Directory('bin/separate');
            // if (!fff.existsSync()) {
            //   await fff.create();
            // } else {
            //   await fff.delete(recursive: true);
            //   await fff.create();
            // }
            separateFile(name,separateInsMap);
            } catch (e) {}
        }
      });
    });

    //创建类maping的映射
    String tempSe = '';
    await separateMaps.forEach((key, value){
      tempSe += '\'$key\':$value,\n';
    });
    // temp = temp.substring(0,classMapping.length-2);
    separateMapping += tempSe;
    separateMapping += '};\n';
    separateMapping += '}';

    separateAll(separateMapping);


    String tempWx = '';
    await wxAllMaps.forEach((key, value){
      tempWx += 'export \'$value\';\n';
    });

    wxAll += tempWx;

    wxAllFile(wxAll);

    print('-----------${num}');
  } catch (e) {
    print(e);
  }

}
separateFile(String name,String separateInsMap) async{
  //实际类映射的创建
  File fileMap = File('bin/sdk/${name}Fof.dart');
  // classBeanMaps['$name'] = '${name}Fof';
  if (await !fileMap.existsSync()) {
    await fileMap.create();
  } else {
    await fileMap.delete(recursive: true);
    await fileMap.create();
  }
  await fileMap.writeAsString(separateInsMap);
}

wxAllFile(String separateInsMap) async{
  //实际类映射的创建
  File fileMap = File('bin/sdk/fof_system.dart');
  // classBeanMaps['$name'] = '${name}Fof';
  if (await !fileMap.existsSync()) {
    await fileMap.create();
  } else {
    await fileMap.delete(recursive: true);
    await fileMap.create();
  }
  await fileMap.writeAsString(separateInsMap);
}


separateAll(String separateMapping) async{
  File fileSe = File('bin/sdk/fof_mapping.dart');
  if (!await fileSe.existsSync()) {
  await fileSe.create();
  } else {
  await fileSe.delete(recursive: true);
  await fileSe.create();
  }
  await fileSe.writeAsString(separateMapping);

}
