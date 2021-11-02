import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:ksh_app/models/web_scraper_nesa.dart';
import 'package:ksh_app/screens/login_screen.dart';
import 'package:ksh_app/widgets/bottom_navigation_bar_widget.dart';

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
    var mediaQuery = MediaQuery.of(context).size;

    readUserData(context);

    Widget builderListTile() {
      return Column(
        children: [
          SizedBox(
            height: mediaQuery.height * 0.012,
          ),
          ListTile(
            minLeadingWidth: mediaQuery.width * 0.14,
            tileColor: Theme.of(context).colorScheme.secondary,
            leading: Icon(
              Icons.school_outlined,
              color: Colors.white,
              size: mediaQuery.height * 0.05,
            ),
            title: Text(
              'Noten Saldo',
              style: TextStyle(
                  color: Colors.white, fontSize: mediaQuery.height * 0.022),
            ),
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

    Widget builderOtherOptions(String title,
        {IconData? icons, String? iconPath}) {
      if (icons == Null) {
        if (iconPath == Null) {
          throw Exception('Icons und IconPath sind leer');
        }
        //todo: Für einen Pfad erstellen
      }
      return Container(
        width: mediaQuery.width * 0.3,
        height: mediaQuery.height * 0.2,
        color: Theme.of(context).colorScheme.secondary,
        margin: EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Icon(
                icons,
                size: mediaQuery.width * 0.3 * 0.7,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      );
    }

    return Scaffold(
      bottomNavigationBar: BottomNavigatioinBarWidget(),
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
        padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 15),
        child: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.secondary,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
              margin: EdgeInsets.only(bottom: mediaQuery.height * 0.015),
            ),
            builderListTile(),
            builderListTile(),
            builderListTile(),
            SizedBox(
              height: mediaQuery.height * 0.03,
            ),
            Text(
              'Weitere',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white, fontSize: mediaQuery.height * 0.022),
            ),
            SizedBox(
              height: mediaQuery.height * 0.017,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  builderOtherOptions('Absenzen', icons: Icons.person_off_outlined),
                  builderOtherOptions('Kontoauszug',
                      icons: Icons.monetization_on),
                  builderOtherOptions('Kalender', icons: Icons.calendar_today),
                  builderOtherOptions('Dein Profil', icons: Icons.person),
                  builderOtherOptions('Absenzen', icons: Icons.markunread_sharp),
                  builderOtherOptions('Absenzen', icons: Icons.ac_unit),
                  builderOtherOptions('Absenzen', icons: Icons.ac_unit),
                  builderOtherOptions('Absenzen', icons: Icons.ac_unit),
                ],
              ),
            )
          ],
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
