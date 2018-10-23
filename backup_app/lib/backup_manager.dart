import 'package:flutter/material.dart';
import 'package:backup_app/server.dart';
import 'package:backup_app/fancy_fab.dart';

class BackupManager extends StatefulWidget {
  @override
  _BackupManager createState() => _BackupManager();
}

class _BackupManager extends State<BackupManager>
    with AutomaticKeepAliveClientMixin<BackupManager> {
  final Map<int, bool> selected = Map();
  List<BackupObject> currentObjs = List();
  Future<List<BackupObject>> _futureObjs;

  @override
  bool get wantKeepAlive => false;

  // @override
  // void initState() {
  //   this.updateState();
  //   super.initState();
  // }

  // void updateState() {
  //   _futureObjs = Server.fetchBackupFolders();
  // }

  Widget _getBackupCard(BackupObject obj, int index) {
    return Card(
        child: ExpansionTile(
            onExpansionChanged: (expanded) {
              setState(() {
                if (expanded) {
                  selected[index] = true;
                } else {
                  selected[index] = false;
                }
              });
            },
            title: Text(obj.name),
            leading: Icon(Icons.backup),
            children: obj.getBackupObjectDropdown()));
  }

  Widget _getListView(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _getBackupCard(currentObjs[index], index);
      },
      itemCount: currentObjs.length,
    );
  }

  void deleteSelected() async {
    setState(() {
      selected.forEach((index, sel) async {
        if (sel) {
          await Server.deleteFolder(currentObjs[index].name);
          currentObjs.removeAt(index);
          selected[index] = false;
          // this.updateState();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FancyFab(onPressedDelete: this.deleteSelected),
        body: FutureBuilder(
          future: Server.fetchBackupFolders(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text("Loading");
            if (snapshot.data.isEmpty) {
              return Text("Nothing to see here...");
            }
            currentObjs = snapshot.data;
            return _getListView(context);
          },
        ));
  }
}
