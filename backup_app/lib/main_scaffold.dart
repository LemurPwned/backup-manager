import 'package:flutter/material.dart';
import 'package:backup_app/dir_crawler.dart';
import 'package:backup_app/backup_manager.dart';
import 'package:backup_app/server.dart';

class MainScaffold extends StatefulWidget {
  @required
  final String ip;
  final String rootDir;
  final List<PageStorage> screens;
  final List<String> names = ["Folder viewer", "Manager"];
  MainScaffold({this.ip, this.rootDir})
      : screens = [
          PageStorage(
              child: DirCrawler(ipAddr: ip, rootDir: rootDir),
              bucket: PageStorageBucket()),
          PageStorage(
              child: BackupManager(ipAddr: ip), bucket: PageStorageBucket()),
        ];

  @override
  MainScaffoldState createState() {
    return new MainScaffoldState();
  }
}

class MainScaffoldState extends State<MainScaffold> {
  int currentScreen = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: buildBottomNavigationBar(context),
        backgroundColor: Color(0xFFF2F2F2),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: widget.screens,
        ));
  }

  BottomNavigationBar buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentScreen,
        onTap: (index) {
          this._pageController.animateToPage(index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut);
          setState(() {
            this.currentScreen = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.view_list), title: Text("Folders")),
          BottomNavigationBarItem(
              icon: Icon(Icons.backup), title: Text("Manager")),
        ]);
  }
}
