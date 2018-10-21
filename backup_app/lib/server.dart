import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class FileObj {
  final String name;
  final String type;
  FileObj({this.name, this.type});
}

class Server {
  static Future<List<FileObj>> fetchDirListings(String currentDir) async {
    final response = await http.get(
        "http://192.168.1.6:5000/getDirectoryListing?root_dir=$currentDir");
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
}
