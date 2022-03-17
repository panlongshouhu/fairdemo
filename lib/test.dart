
import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter/material.dart';
void main(List<String> arguments) {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(Home());

  // Runtime.convertClass('Text').then((value) {
  //   value = value as Widget;
  //   print(value.runtimeType);
  // });
  // dynamic an = Function.apply('() => Animal',null);

  final parser = ArgParser()
    ..addOption('file', abbr: 'f')
    ..addOption('directory', abbr: 'd')
    ..addOption('output-directory', abbr: 'o')
    ..addOption('sdk-name', abbr: 's')
    ..addOption('compile-kind',
        abbr: 'k',
        defaultsTo: 'bundle',
        allowed: ['bundle', 'dart', 'flutter', 'sdk']);
  var argResults = parser.parse(arguments);
  var kind = argResults['compile-kind'];
  if (kind == 'bundle') {
    var file = argResults['file'];
    if (file == null || !File(file).existsSync()) {
      print('file is required, please pass as absolute path');
    }

  } else if (kind == 'dart') {
    var dirString = argResults['directory'];
    Directory dir;
    if (dirString == null || !(dir = Directory(dirString)).existsSync()) {
      print('directory is not valid, please pass as absolute path');
    }
  } else if (kind == 'flutter') {
    var dir = argResults['directory'];
    if (dir == null || !(Directory(dir)).existsSync()) {
      print('directory is not valid, please pass as absolute path');
    }
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Center(
        child: Text('data'),
      ),
    );
  }
}
