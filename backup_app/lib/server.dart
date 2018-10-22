import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class FileObj {
  final String name;
  final String type;
  FileObj({this.name, this.type});
}

final String ipAddr = "192.168.1.6:5000";

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

  static Future<List<FileObj>> fetchBackupFolders(String currentDir) async {
    final response = await http
        .get("http://$ipAddr/getDirectoryListing?root_dir=$currentDir");
    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      print(res);
      List<FileObj> objects = List();
      res.forEach((el) =>
          objects.add(FileObj(name: el['folderDst'].toString(), type: 'b')));
      return objects;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load file listings');
    }
  }

  static Future<http.Response> postRequest(String folderDst) async {
    var url = 'http://$ipAddr/addBackupFolder';
    var body = jsonEncode({'folderDst': folderDst});

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
