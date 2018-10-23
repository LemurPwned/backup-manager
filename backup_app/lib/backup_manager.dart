import 'package:flutter/material.dart';
import 'package:backup_app/server.dart';
import 'package:backup_app/fancy_fab.dart';

class BackupManager extends StatefulWidget {
  @override
  _BackupManager createState() => _BackupManager();
}

class _BackupManager extends State<BackupManager> {
  // final Map<BackupObject, bool> backupList;
  final Map<int, bool> selected = Map();
  List<BackupObject> currentObjs = List();

  Widget _getBackupCard(BackupObject obj, int index) {
    return Card(
        child: ExpansionTile(
            onExpansionChanged: (expanded) {
              print("CHANGED EXPANDED");
              setState(() {
                if (expanded) {
                  print("SELECTED TRUE");
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
    print("DELETE");
    setState(() {
      selected.forEach((index, sel) async {
        if (sel) {
          await Server.deleteFolder(currentObjs[index].name);
          currentObjs.removeAt(index);
          selected[index] = false;
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
