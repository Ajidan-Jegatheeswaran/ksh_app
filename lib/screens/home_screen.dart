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

  @override
  Widget build(BuildContext context) {
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
              color: Colors.red,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
            ),
            /*ListView.builder(
              itemBuilder: (ctx, index) => Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.2,
                color: Colors.red,
              ),
              shrinkWrap: true,
            )*/
          ],
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
