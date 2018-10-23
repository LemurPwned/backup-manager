import 'package:flutter/material.dart';
import 'package:backup_app/server.dart';
import 'package:backup_app/backup_manager.dart';

final TextStyle secondaryStyle = TextStyle(
    fontFamily: "Roboto",
    fontSize: 12.0,
    letterSpacing: -0.12,
    fontWeight: FontWeight.normal);

class DirCrawler extends StatefulWidget {
  @required
  final BackupManager bm;

  DirCrawler({this.bm});
  @override
  _DirCrawler createState() => _DirCrawler();
}

class _DirCrawler extends State<DirCrawler>
    with AutomaticKeepAliveClientMixin<DirCrawler> {
  String currentDir = '.';
  String lastDir = '.';
  Map<String, bool> backupDirs = Map();
  Future<List<FileObj>> _fileObjs;

  @override
  void initState() {
    _fileObjs = Server.fetchDirListings(currentDir);
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  bool selectedIcon = false;

  bool isSelected(String lab) {
    if (backupDirs.containsKey(lab)) {
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
                    if (backupDirs.containsValue(true) && !this.selectedIcon) {
                      setState(() {
                        this.selectedIcon = true;
                      });
                    } else if (!backupDirs.containsValue(true) &&
                        this.selectedIcon) {
                      setState(() {
                        this.selectedIcon = false;
                      });
                    }
                  });
                },
                onTap: () {
                  if (typeList == 'directory') {
                    backupDirs.forEach((f, _) {
                      backupDirs[f] = false;
                    });

                    setState(() {
                      lastDir = currentDir;
                      currentDir = currentDir + '/' + listing;
                      this.selectedIcon = false;
                      _fileObjs = Server.fetchDirListings(currentDir);
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
            // delete trailing slash
            if (currentDir != '.') {
              int lastSlash = currentDir.lastIndexOf('/');
              currentDir = currentDir.substring(0, lastSlash);
              _fileObjs = Server.fetchDirListings(currentDir);
            }
            // if selected then send to the server
            if (this.selectedIcon) {
              backupDirs.forEach((folder, _) {
                Server.postRequest(folder);
                // unselect all
                backupDirs[folder] = false;
              });
              this.selectedIcon = false;
              // this.widget.bm.bmKey.currentState.updateState();
            }
          });
        },
        key: Key("back"),
        child: Icon(
          this.selectedIcon ? Icons.add : Icons.keyboard_backspace,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomSheet: _getCurrentDirCard(),
        body: FutureBuilder(
            future: _fileObjs,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Text("Loading");
              return _getListView(snapshot.data, context);
            }),
        floatingActionButton: _getFABBack());
  }
}
