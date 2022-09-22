import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:message_app/viewModel/auth_util.dart';
import 'package:message_app/theme/app_state.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.onSurface,
      appBar: new CupertinoNavigationBar(
          backgroundColor: colorScheme.onPrimary,
          leading: CupertinoButton(
            minSize: 15,
            padding: EdgeInsets.all(0),
            child: CircleAvatar(
              backgroundColor: colorScheme.onSurface,
              child: Icon(
                CupertinoIcons.chevron_back,
                size: 24,
                color: colorScheme.onSecondary,
              ),
              radius: 15,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ), middle: Text("Settings"),),
      body: SafeArea(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              child: Column(
                children: [
                  CupertinoButton(
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.power),
                        Text("   Logout", style: TextStyle(color: colorScheme.secondaryVariant, fontSize: 14, fontWeight: FontWeight.w400),),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => CupertinoActionSheet(
                          title: new Text(
                            "Warning!",
                            style: TextStyle(color: colorScheme.primary),
                          ),
                          message: new Text(
                              "You really want to logout from this device?"),
                          actions: [
                            CupertinoActionSheetAction(
                              child: new Text("Yes"),
                              onPressed: () {
                                AuthUtil.logout(context);
                              },
                            )
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            child: new Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
