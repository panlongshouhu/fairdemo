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
    'dart:isolate',
    'dart:mirrors'
  ];
  librarys.forEach((element) {
    try {
      element = element.replaceAll(':', '.');
      LibraryMirror libraryMirror =
          currentMirrorSystem().findLibrary(new Symbol(element));


      libraryMirror.declarations.forEach((key, value) async {
        var classOutMethod = {};
        if (value is ClassMirror) {
          String name = MirrorSystem.getName(key);
          if (!name.startsWith('_')) {
            value.declarations.forEach((key, declaration) async{
              MethodMirror method;
              if (declaration is MethodMirror) method = declaration;
              if(method == null)return;
              if (method.isConstructor) {
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
                dynamic function = (List<dynamic> positionalArgs) => value
                    .newInstance(method.constructorName, positionalArgs)
                    .reflectee;
                Mapping.map[name] = function;
              }else{
                String methodName = MirrorSystem.getName(key);
                classOutMethod[methodName] = method;
              }
            });

            //方法输出
            try {
              var ff = Directory('bin/bean');
              if(!ff.existsSync()){
                await ff.create();
              }else{
                 await ff.delete(recursive:true);
                 await ff.create();
              }
              File file = File('bin/bean/${name}Ex.dart');
              if(!await file.existsSync()){
                await file.create();
              }
              String classMap = '''extension ${name}Ex on $name {\ndynamic invoke(String name,[dynamic params]){
              if(name.isEmpty)return;\n''';
              classOutMethod.forEach((key, value) async{
                // var value1 = MirrorSystem.getName(key);
                classMap += 'if(name.endsWith(\'$key\')){\n';
                var valueString = value.toString().replaceAll('MethodMirror on ', '').replaceAll('\'', '');
                classMap += 'return ${valueString}();';
                classMap += '\n}\n';
              });
              classMap += 'return null;\n';
              classMap +='}\n';
              classMap +='}';
              await file.writeAsString(classMap);
            } catch (e) {
            }
          }
        }
      });
    } catch (e) {}
  });
  // String test = 'Utf8Codec';
  String test = 'File';
  var df = Uint8List(2);
  // String test = 'ZLibCodec';
  // String test = 'JsonUnsupportedObjectError';
  dynamic fun = Function.apply(Mapping.map[test], [[df]]);
  print(fun.toString());
  //类创建
  File file = File('bin/map.json');
  try {
    String classMap = '[\n';
    Mapping.map.forEach((key, value) {
      String valueString = value.toString().replaceAll("Closure: ", "");
      classMap += '{\n\"key\":\"$key\",\n\"value\":\"$valueString\"\n},\n';
    });
    classMap = classMap.substring(0, classMap.length - 2);
    classMap += '\n]';
    await file.writeAsString(classMap);
  } catch (e) {
    print(e);
  }

  // dynamic fff = Function.apply((String name,int age1) => Animal(name,age:age1), ['dd',22]);
  // print(fff.name);
  // print(fff.age);
}

class Animal {
  String name = '2332';
  int age = 324;
  Animal(this.name, {this.age});
  void dfd({int qqq}) {}
}
