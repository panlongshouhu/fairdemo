import 'dart:async';
import 'dart:io';
import 'dart:mirrors';
import 'dart:typed_data';
import 'bean_mapping.dart';
import 'class_mapping.dart';
import 'mapping.dart';

void main(List<String> arguments) {
  var fun = Function.apply(ClassFof.maps['Int32List']['Int32List'], [16]);
  var int32 = Int32List(1);
  print(int32.length);
  print(fun.length);
}
