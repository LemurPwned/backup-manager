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
  Map<String, bool> backupDirs = Map();

  bool selected_icon = false;

  bool isSelected(String lab) {
    print("CALLED $lab");
    if (backupDirs.containsKey(lab)) {
      print(backupDirs[lab]);
      return backupDirs[lab];
    } else {
      return false;
    }
  }

  Widget _getListingCard(
      String listing, String typeList, BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme(
              selectedColor: Colors.lightBlue,
              child: ListTile(
                onLongPress: () {
                  setState(() {
                    if (backupDirs.containsKey(currentDir + '/' + listing)) {
                      backupDirs[currentDir + '/' + listing] =
                          !backupDirs[currentDir + '/' + listing];
                    } else {
                      backupDirs[currentDir + '/' + listing] = true;
                    }
                    if (backupDirs.containsValue(true) && !this.selected_icon) {
                      setState(() {
                        print("SOMETHING SELECTED");
                        this.selected_icon = true;
                      });
                    } else if (!backupDirs.containsValue(true) &&
                        this.selected_icon) {
                      print("NOTHING SELECTED");
                      setState(() {
                        this.selected_icon = false;
                      });
                    }
                  });
                },
                onTap: () {
                  if (typeList == 'directory') {
                    setState(() {
                      lastDir = currentDir;
                      currentDir = currentDir + '/' + listing;
                      print("CLICKED $currentDir");
                    });
                  }
                },
                selected: isSelected(currentDir + '/' + listing),
                leading: typeList == "file"
                    ? Icon(Icons.insert_drive_file)
                    : Icon(Icons.folder),
                title: Text(listing, style: secondaryStyle),
                subtitle: Text(typeList, style: secondaryStyle),
              )),
        ],
      ),
    );
  }

  Widget _getListView(List<FileObj> listing, BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _getListingCard(
            listing[index].name, listing[index].type, context);
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
            if (this.selected_icon) {
              backupDirs.forEach((folder, _) => Server.postRequest(folder));
            }
          });
        },
        key: Key("back"),
        child: Icon(
          this.selected_icon ? Icons.add : Icons.keyboard_backspace,
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
              return _getListView(snapshot.data, context);
            }),
        floatingActionButton: _getFABBack());
  }
}
