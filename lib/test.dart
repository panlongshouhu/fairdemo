import 'dart:convert';

import 'package:args/args.dart';
import 'package:flutter/material.dart';

import 'runtime/runtime.dart';

void main(List<String> arguments) {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(Home());
  final parser = ArgParser()..addOption('file', abbr: 'f')
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
    if (kind == 'flutter') {
      var dir = argResults['directory'];
      print(dir);
    }
  }

  var objects = Runtime.convertClass('Text');
  print(arguments.toString());

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
