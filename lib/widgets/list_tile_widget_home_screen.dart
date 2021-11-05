import 'package:flutter/material.dart';

class ListTileWigetHomeScreen extends StatelessWidget {
  var mediaQuery;
  String text;
  String result;

  ListTileWigetHomeScreen(this.mediaQuery, String this.text, String this.result);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minLeadingWidth: mediaQuery.width * 0.14,
      tileColor: Theme.of(context).colorScheme.secondary,
      leading: Icon(
        Icons.school_outlined,
        color: Colors.white,
        size: mediaQuery.height * 0.05,
      ),
      title: Text(
        text,
        style:
            TextStyle(color: Colors.white, fontSize: mediaQuery.height * 0.022),
      ),
      trailing: Padding(
        padding: EdgeInsets.only(right: mediaQuery.width * 0.11),
        child: Text(
          text,
          style: TextStyle(
              color: Colors.white, fontSize: mediaQuery.height * 0.03),
        ),
      ),
    );
  }
}