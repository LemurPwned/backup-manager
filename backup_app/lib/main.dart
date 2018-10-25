import 'package:flutter/material.dart';
import 'package:backup_app/dir_crawler.dart';
import 'package:backup_app/backup_manager.dart';

void main() => runApp(new BackupApp());

class BackupApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Backup Manager',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MainScaffold());
  }
}

class MainScaffold extends StatefulWidget {
  static final bm = BackupManager();
  final screens = [
    PageStorage(child: DirCrawler(bm: bm), bucket: PageStorageBucket()),
    PageStorage(child: bm, bucket: PageStorageBucket()),
  ];
  final List<String> names = ["Folder viewer", "Manager"];

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
