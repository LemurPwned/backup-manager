import 'package:flutter/material.dart';
import 'package:backup_app/server.dart';
import 'package:backup_app/fancy_fab.dart';
import 'package:backup_app/globals.dart';

class BackupManager extends StatefulWidget {
  final String ipAddr;
  BackupManager({this.ipAddr});
  @override
  _BackupManager createState() => _BackupManager();
}

class _BackupManager extends State<BackupManager> {
  final Map<int, bool> selected = Map();
  List<BackupObject> currentObjs = List();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = new GlobalKey<FormState>();

  final passwordFieldController = TextEditingController();
  final folderFieldController = TextEditingController();
  bool passwordLock = false;
  String passwordCont;
  Future<List<BackupObject>> _futureObjs;

  @override
  void initState() {
    this.updateState();
    super.initState();
  }

  void updateState() {
    _futureObjs = Server.fetchBackupFolders(this.widget.ipAddr);
  }

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
    List<int> removeIndicies = List();
    selected.forEach((index, sel) async {
      if (sel) {
        await Server.deleteFolder(currentObjs[index].name, this.widget.ipAddr);
        currentObjs.removeAt(index);
        selected[index] = false;
        removeIndicies.add(index);
      }
    });
    setState(() {
      removeIndicies.forEach((index) => currentObjs.removeAt(index));
    });
  }

  void encryptSelected(BuildContext context) async {
    await _getAlertForEncryption(context);
    if (passwordLock) {
      backupUpdate(passwordCont);
      passwordLock = false;
      passwordCont = "";
    }
  }

  void backupUpdate(String encryptionPass) {
    setState(() {
      selected.forEach((index, sel) async {
        if (sel) {
          await Server.backupFolder(
              currentObjs[index].name, encryptionPass, this.widget.ipAddr);
          this.selected[index] = false;
        }
      });
      this.updateState();
    });
  }

  void backUpSelected() async {
    this.backupUpdate("");
  }

  Future<Widget> _getAlertForBackupChange(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Encryption settings"),
              content: Container(
                height: 150.0,
                width: 80.0,
                child: getFolderForm(),
              ));
        });
  }

  Future<Widget> _getAlertForEncryption(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Encryption settings"),
              content: Container(
                height: 150.0,
                width: 80.0,
                child: getPassForm(),
              ));
        });
  }

  Column getFolderForm() {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(left: 25.0, right: 25.0),
          child: Form(
              key: this._formKey2,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: folderFieldController,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                      hintText: 'BACKUPS', labelText: 'Backup folder'),
                ),
              ]))),
      ButtonBar(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              if (this._formKey2.currentState.validate()) {
                Server.changeBackupDir(
                    this.folderFieldController.text, this.widget.ipAddr);
                Navigator.of(context).pop();
              }
            },
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.blueAccent,
          ),
          RaisedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.blueAccent,
          )
        ],
      )
    ]);
  }

  Column getPassForm() {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(left: 25.0, right: 25.0),
          child: Form(
              key: this._formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: passwordFieldController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: new InputDecoration(
                      hintText: 'type here', labelText: 'password'),
                ),
              ]))),
      ButtonBar(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              if (this._formKey.currentState.validate()) {
                passwordLock = true;
                passwordCont = this.passwordFieldController.text;
                Navigator.of(context).pop();
              }
            },
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.blueAccent,
          ),
          RaisedButton(
            onPressed: () {
              if (this._formKey.currentState.validate()) {
                passwordLock = false;
                passwordCont = "";
                Navigator.of(context).pop();
              }
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.blueAccent,
          )
        ],
      )
    ]);
  }

  Widget changeBackupFolder(BuildContext context) {
    return Text("HELLO");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.blur_circular),
          title: Text("Backup viewer"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () async => await _getAlertForBackupChange(context),
            )
          ],
        ),
        floatingActionButton: FancyFab(
            onPressedDelete: this.deleteSelected,
            onPressedBackup: this.backUpSelected,
            onPressedEncrypt: encryptSelected),
        body: FutureBuilder(
          future: _futureObjs,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return getNothingScreen("Loading");
            if (snapshot.data.isEmpty) {
              return getNothingScreen("Nothing to see here...");
            }
            currentObjs = snapshot.data;
            return _getListView(context);
          },
        ));
  }
}
