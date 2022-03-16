import 'dart:convert';

import 'package:fair/fair.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FairApp.runApplication(
    _getApp(),
    plugins: {
    },
  );
}


dynamic _getApp() => FairApp(
  modules: {
  },
  delegate: {
  },
  child: MaterialApp(
    home: FairWidget(
        name: 'IfEqualBoolPage',
        path: 'assets/lib_bool_page.fair.json',
        data: {"fairProps": json.encode({'pageName':'pageName','count':0})}),
  ),
);
