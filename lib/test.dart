
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
  dynamic an = Function.apply((String name) => Animal(name),['ddd']);
  print(an.name);
}

class Animal {
  String name;
  Animal(this.name);
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
