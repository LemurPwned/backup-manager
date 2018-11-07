import 'package:flutter/material.dart';
import 'package:backup_app/main_scaffold.dart';
import 'globals.dart';

class SplashForm extends StatefulWidget {
  @override
  _SplashForm createState() => _SplashForm();
}

class _SplashForm extends State<SplashForm> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final ipAddrFieldController = TextEditingController();
  RegExp regExp = new RegExp(
    r"^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$",
    caseSensitive: false,
    multiLine: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: getForm(context));
  }

  Column getForm(context) {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 150.0),
          child: Column(children: <Widget>[
            Text(
              "Enter the IPv4 address of the backup server",
              style: newStyle,
            ),
            Form(
                key: this._formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    controller: ipAddrFieldController,
                    keyboardType: TextInputType.number,
                    validator: (ipText) {
                      if (!regExp.hasMatch(ipText) || ipText.isEmpty) {
                        return "Invalid IPv4 address";
                      }
                    },
                    decoration: new InputDecoration(
                        icon: Icon(Icons.network_check),
                        hintText: 'e.g 192.168.1.5',
                        labelText: 'ip address'),
                  ),
                ]))
          ])),
      ButtonBar(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              if (this._formKey.currentState.validate()) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MainScaffold(ip: this.ipAddrFieldController.text)));
              }
            },
            child: Text(
              "Confirm",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.blueAccent,
          )
        ],
      )
    ]);
  }
}
