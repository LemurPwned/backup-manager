import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:backup_app/server.dart';

class FileIO {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/backupSpace.json');
  }

  Future<File> saveLabelsToLabelSpace(Map<String, FileObj> labelMap) async {
    final file = await _localFile;
    final stringLabelMap = json.encode(labelMap);

    return file.writeAsString(stringLabelMap);
  }
}
