
import 'dart:math';
import 'dart:mirrors';

import 'mapping.dart';

void main(List<String> arguments) async{
  // InstanceMirror classMirror = reflect(() =>
  //     Random()) as InstanceMirror; //类名即是Type
  // print(classMirror.reflectee.runtimeType);
  // Random random = Random();
  // print(random.runtimeType);

  // ClassMirror c = reflectClass('Random');
  // InstanceMirror im = c.newInstance(const Symbol(''), ['MyAttributeValue']);
  // var o = im.reflectee;
  // String test = 'FormatException';
  LibraryMirror libraryMirror = currentMirrorSystem().findLibrary(
      new Symbol('dart.core'));
  libraryMirror.declarations.forEach((key, value) async {

    // print(value.toString());
    // DeclarationMirror classMirror = value;
    if (value is ClassMirror) {
      String name = MirrorSystem.getName(key);
      if (!name.startsWith('_')) {
        value.declarations.forEach((symbol, declarationMirror) {
          // print(MirrorSystem.getName(symbol));
        });

        // This doesn't show me the constructor
        // print("+ Members");
        // value.instanceMembers.forEach((symbol, methodMirror) {
        //   print(MirrorSystem.getName(symbol));
        // });
        // value.metadata.forEach((element) {
        //   element.
        // });
        Function function = () => value.newInstance(Symbol(name), []);
        Mapping.map[name] = function;

        // var instance = value.newInstance(Symbol.empty, []);
        // print(instance);
        // value.instanceMembers.forEach((key, value) {
        //   print(value.constructorName);
        // });
      }
    }

  });
  Mapping.map.forEach((key, value) {
    print("$key +${value.toString()}");
  });
  // print(libraryMirror.declarations);

  // InstanceMirror result = null;
  // Symbol symbol = new Symbol('String');
  // result = currentMirrorSystem().isolate.rootLibrary.invoke(symbol,null);
  // print(result.toString());
}