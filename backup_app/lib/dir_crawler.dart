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
  String lastDir = '.';
  Widget _getListingCard(String listing, String typeList) {
    return GestureDetector(
        onTap: () {
          if (typeList == 'directory') {
            setState(() {
              lastDir = currentDir;
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

  Widget _getCurrentDirCard() {
    return Card(
      color: Colors.grey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.folder_special),
            title: Text("Current folder: $currentDir", style: secondaryStyle),
          ),
        ],
      ),
    );
  }

  Widget _getFABBack() {
    return FloatingActionButton(
        onPressed: () {
          setState(() {
            if (currentDir != '.') {
              int lastSlash = currentDir.lastIndexOf('/');
              currentDir = currentDir.substring(0, lastSlash);
            }
          });
        },
        key: Key("back"),
        child: Icon(
          Icons.keyboard_backspace,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomSheet: _getCurrentDirCard(),
        body: FutureBuilder(
            future: Server.fetchDirListings(currentDir),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Text("Loading");
              return _getListView(snapshot.data);
            }),
        floatingActionButton: _getFABBack());
  }
}
