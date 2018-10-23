import 'package:flutter/material.dart';

class FancyFab extends StatefulWidget {
  final Function() onPressedDelete;
  final Function() onPressedBackup;
  final Function() onPressedEncrypt;
  final String tooltip;
  final IconData icon;

  FancyFab(
      {this.onPressedDelete,
      this.onPressedBackup,
      this.onPressedEncrypt,
      this.tooltip,
      this.icon});

  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget backup() {
    return Container(
      child: FloatingActionButton(
        onPressed: this.widget.onPressedBackup,
        tooltip: 'Backup',
        child: Icon(Icons.cloud_upload),
      ),
    );
  }

  Widget encrypted() {
    return Container(
      child: FloatingActionButton(
        onPressed: this.widget.onPressedEncrypt,
        tooltip: 'Encrypted backup',
        child: Icon(Icons.lock),
      ),
    );
  }

  Widget delete() {
    return Container(
      child: FloatingActionButton(
        onPressed: this.widget.onPressedDelete,
        tooltip: 'Delete',
        child: Icon(Icons.delete),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 3.0,
            0.0,
          ),
          child: backup(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: encrypted(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: delete(),
        ),
        toggle(),
      ],
    );
  }
}
