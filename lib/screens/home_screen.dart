import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:ksh_app/models/web_scraper_nesa.dart';
import 'package:ksh_app/screens/login_screen.dart';
import 'package:ksh_app/widgets/mark_list_tile.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  //ReadUserData Variabeln
  Map<String, dynamic> _userData = {};
  late Directory dir;
  late File jsonFile;
  String fileName = 'userData.json';
  bool fileExists = false;

  Future<void> readUserData(BuildContext ctx) async {
    await getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = File(dir.path + '/' + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) {
        String resJsonFile = jsonFile.readAsStringSync();
        _userData = convert.jsonDecode(resJsonFile);
        print(_userData);
      } else {
        Navigator.of(ctx).pushReplacementNamed(LoginScreen.routeName);
      }
    });
  }

  Widget builderListTile(BuildContext ctx, var mediaQuery) {
    return Column(
      children: [
        SizedBox(
          height: mediaQuery.height * 0.012,
        ),
        ListTile(
          minLeadingWidth: mediaQuery.width * 0.125,
          tileColor: Theme.of(ctx).colorScheme.secondary,
          leading: const Icon(Icons.ac_unit, color: Colors.white,),
          title: Text('Noten Saldo', style: TextStyle(color: Colors.white, fontSize: mediaQuery.height * 0.022),),
          trailing: Padding(
            padding: EdgeInsets.only(right: mediaQuery.width * 0.11),
            child: Text(
              '2',
              style: TextStyle(
                  color: Colors.white, fontSize: mediaQuery.height * 0.03),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    //readUserData(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {}, //TODO: Verlinkung zum ProfilScreen()
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {}, //Todo: Noten hinzufügen Screen oder Bottom Sheet
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.secondary,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
              margin: EdgeInsets.only(bottom: mediaQuery.height * 0.015),
            ),
            builderListTile(context, mediaQuery),
            builderListTile(context, mediaQuery),
            builderListTile(context, mediaQuery),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
