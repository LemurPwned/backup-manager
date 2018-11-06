import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:backup_app/globals.dart';

class BackupObject {
  @required
  String lastUpdateDate;
  @required
  String absolutePath;
  @required
  String name;
  String encrypted = "false";
  String lastBackup;

  BackupObject(
      {this.lastUpdateDate,
      this.absolutePath,
      this.name,
      this.encrypted,
      this.lastBackup});

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
      Text(
        "last_backup: ${this.lastBackup}",
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

// 10.129.12.177
// 192.168.1.6:5000
class Server {
  final String ipAddr;
  Server({@required this.ipAddr});

  Future<List<FileObj>> fetchDirListings(String currentDir) async {
    final response = await http.get(
        "http://${this.ipAddr}:5000/getDirectoryListing?root_dir=$currentDir");
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

  Future<List<BackupObject>> fetchBackupFolders() async {
    final response =
        await http.get("http://${this.ipAddr}:5000/getBackupFolders");
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      if (res == null) {
        return null;
      }
      List<BackupObject> objects = List();
      res.forEach((name, el) => objects.add(BackupObject(
          name: el['name'].toString(),
          encrypted: el['encrypted'].toString(),
          absolutePath: el['absolutePath'].toString(),
          lastUpdateDate: el['updated'],
          lastBackup: el['last_backup'])));
      return objects;
    } else if (response.statusCode == 404) {
      return List();
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load file backups');
    }
  }

  Future<void> deleteFolder(String folder) async {
    final response = await http
        .get("http://${this.ipAddr}:5000/manageBackupFolder?to_delete=$folder");
    if (response.statusCode == 200) {
      print("SUCCESSFULLY DELETED $folder");
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to delete');
    }
  }

  Future<void> backupFolder(String folder, String encrypted) async {
    final response = await http.get(
        "http://${this.ipAddr}:5000/manageBackupFolder?folder=$folder&encrypted=$encrypted");
    if (response.statusCode == 200) {
      print("SUCCESSFULLY BACKED UP $folder with $encrypted");
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to backup');
    }
  }

  Future<void> changeBackupDir(String folder) async {
    final response = await http
        .get("http://${this.ipAddr}:5000/manageBackupFolder?change=$folder");
    if (response.statusCode == 200) {
      print("SUCCESSFULLY CHANGED $folder");
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to backup');
    }
  }

  Future<http.Response> postRequest(String folderDst) async {
    String name;
    if (folderDst.contains('/'))
      name = folderDst.substring(folderDst.lastIndexOf('/') + 1);
    else
      name = folderDst;
    print("The name $name");
    var url = 'http://${this.ipAddr}:5000/addBackupFolder';
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
