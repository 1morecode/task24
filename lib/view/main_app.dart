import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:message_app/res/user_token.dart';
import 'package:message_app/view/blog_app.dart';
import 'package:message_app/view/message_app.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  @override
  void initState() {
    UserToken.saveUserToDatabase();
    UserToken.updateTimeInDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(body: CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_text),
            label: 'Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_text),
            label: 'Messages',
          )
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            if(index == 1){
              return MessageApp();
            }else{
              return BlogApp();
            }
          },
        );
      },
    ),);
  }
}
