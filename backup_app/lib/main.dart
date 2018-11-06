import 'package:flutter/material.dart';
import 'package:backup_app/splash_form.dart';

void main() => runApp(new BackupApp());

class BackupApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Backup Manager',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashForm());
  }
}
