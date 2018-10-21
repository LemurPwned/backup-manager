import 'package:flutter/material.dart';
import 'package:backup_app/server.dart';

final TextStyle secondaryStyle = TextStyle(
    fontFamily: "Roboto",
    fontSize: 12.0,
    letterSpacing: -0.12,
    fontWeight: FontWeight.normal);

class DirCrawler extends StatefulWidget {
  @override
  _DirCrawler createState() => _DirCrawler();
}

class _DirCrawler extends State<DirCrawler> {
  String currentDir = '.';

  Widget _getListingCard(String listing, String typeList) {
    return GestureDetector(
        onTap: () {
          if (typeList == 'directory') {
            setState(() {
              currentDir = currentDir + '/' + listing;
              print("CLICKED $currentDir");
            });
          }
        },
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: typeList == "file"
                    ? Icon(Icons.insert_drive_file)
                    : Icon(Icons.folder),
                title: Text(listing, style: secondaryStyle),
                subtitle: Text(typeList, style: secondaryStyle),
              ),
            ],
          ),
        ));
  }

  Widget _getListView(List<FileObj> listing) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _getListingCard(listing[index].name, listing[index].type);
      },
      itemCount: listing.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: Server.fetchDirListings(currentDir),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Text("Loading");
              return _getListView(snapshot.data);
            }),
        floatingActionButton: FloatingActionButton(
            onPressed: () => print("Pressed"),
            key: Key("back"),
            child: Icon(
              Icons.keyboard_backspace,
            )));
  }
}
