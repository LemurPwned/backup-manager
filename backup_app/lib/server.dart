import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

final newStyle = TextStyle(fontFamily: 'Roboto', fontSize: 12.0);

class BackupObject {
  @required
  String lastUpdateDate;
  @required
  String absolutePath;
  @required
  String name;
  bool encrypted = false;

  BackupObject(
      {this.lastUpdateDate, this.absolutePath, this.name, this.encrypted});

  List<Widget> getBackupObjectDropdown() {
    return [
      Text(
        "Updated: ${this.lastUpdateDate}",
        style: newStyle,
        textAlign: TextAlign.left,
      ),
      Text(
        "Path: ${this.absolutePath}",
        style: newStyle,
        textAlign: TextAlign.left,
      ),
      Text(
        "encrypted: ${this.encrypted}",
        style: newStyle,
        textAlign: TextAlign.left,
      ),
    ];
  }
}

class FileObj {
  final String name;
  final String type;
  FileObj({this.name, this.type});
}

final String ipAddr = "192.168.1.6:5000";

// 10.129.12.177
// 192.168.1.6:5000
class Server {
  static Future<List<FileObj>> fetchDirListings(String currentDir) async {
    final response = await http
        .get("http://$ipAddr/getDirectoryListing?root_dir=$currentDir");
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      print(res);
      List<FileObj> objects = List();
      res.forEach((el) => objects.add(
          FileObj(name: el['name'].toString(), type: el['type'].toString())));
      return objects;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load file listings');
    }
  }

  static Future<List<BackupObject>> fetchBackupFolders() async {
    final response = await http.get("http://$ipAddr/getBackupFolders");
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res == null) {
        return null;
      }
      List<BackupObject> objects = List();
      res.forEach((name, el) => objects.add(BackupObject(
          name: el['name'].toString(),
          encrypted: el['encrypted'],
          absolutePath: el['absolutePath'].toString(),
          lastUpdateDate: el['updated'])));
      return objects;
    } else if (response.statusCode == 404) {
      return List();
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load file backups');
    }
  }

  static Future<void> deleteFolder(String folder) async {
    final response =
        await http.get("http://$ipAddr/deleteBackupFolder?folder=$folder");
    if (response.statusCode == 200) {
      print("SUCCESSFULLY DELETED $folder");
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to delete');
    }
  }

  static Future<http.Response> postRequest(String folderDst) async {
    String name;
    if (folderDst.contains('/'))
      name = folderDst.substring(folderDst.lastIndexOf('/') + 1);
    else
      name = folderDst;
    print("The name $name");
    var url = 'http://$ipAddr/addBackupFolder';
    var body = jsonEncode({
      'name': name,
      'encrypted': false,
      'absolutePath': folderDst,
      'updated': DateTime.now().toString()
    });

    print("Body: " + body);

    http
        .post(url, headers: {"Content-Type": "application/json"}, body: body)
        .then((http.Response response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.contentLength}");
      print(response.headers);
      print(response.request);
    }).then((response) {
      return response;
    });
  }
}
