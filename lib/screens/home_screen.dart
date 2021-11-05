import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:ksh_app/models/web_scraper_nesa.dart';
import 'package:ksh_app/screens/login_screen.dart';
import 'package:ksh_app/widgets/bottom_navigation_bar_widget.dart';

import 'package:path_provider/path_provider.dart';
import 'package:web_scraper/web_scraper.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  Map<String, dynamic> userMarks = {};
  String userSaldo = '';

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

  Future<void> getUserData(BuildContext ctx) async {
    await readUserData(ctx);
    WebScraperNesa webScraperNesa = WebScraperNesa(
        username: _userData['username'],
        password: _userData['password'],
        host: _userData['host']);
    await webScraperNesa.login();
    print('Hat es Funktioniert?: ' + webScraperNesa.isLogin().toString());
    userMarks = await webScraperNesa.getMarksData();
    print('Noten');
    print(userMarks);
  }

  Future<void> saldo() async {
    List<double> noten = [];
    double saldo = 0;

    for (dynamic i in userMarks.values) {
      String stringMark =
          i.toString().split(',')[1].split(':')[1].replaceAll(' ', '');
      if (stringMark == 'NoMark') {
        continue;
      }

      print('keys');
      print(i.toString());
      double doubleNote = double.parse(stringMark);
      noten.add(doubleNote);
    }
    print('Noten Saldo Noten');
    print(noten);

    for (double mark in noten) {
      double resMarkSaldo = mark - 4;
      if (resMarkSaldo == 0) {
        continue;
      }
      if (resMarkSaldo > 0) {
        while (resMarkSaldo >= 1) {
          resMarkSaldo = resMarkSaldo - 1;
          saldo += 1;
        }
        while (resMarkSaldo >= 0.5) {
          resMarkSaldo = resMarkSaldo - 0.5;
          saldo += 0.5;
        }
        if (resMarkSaldo >= 0.25) {
          resMarkSaldo = 0;
          saldo += 0.5;
        } else if (resMarkSaldo < 0.25) {
          continue;
        } else {
          throw Exception(); //todo: Exception
        }
      } else if (resMarkSaldo < 0) {
        resMarkSaldo = -resMarkSaldo;
        if (resMarkSaldo > 0) {
          while (resMarkSaldo >= 1) {
            resMarkSaldo = resMarkSaldo - 1;
            saldo -= 2;
          }
          while (resMarkSaldo >= 0.5) {
            resMarkSaldo = resMarkSaldo - 0.5;
            saldo -= 1;
          }
          if (resMarkSaldo >= 0.25) {
            resMarkSaldo = 0;
            saldo -= 1;
          } else if (resMarkSaldo < 0.25) {
            continue;
          } else {
            throw Exception(); //todo: Exception
          }
        }
      } else {
        throw Exception(); //todo: Exception
      }
    }
    userSaldo = saldo.toString();
  }

  void setUserData(BuildContext context) async {
    await getUserData(context);
    await saldo();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    setUserData(context);

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
                userSaldo,
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
                  builderOtherOptions('Absenzen',
                      icons: Icons.person_off_outlined),
                  builderOtherOptions('Kontoauszug',
                      icons: Icons.monetization_on),
                  builderOtherOptions('Kalender', icons: Icons.calendar_today),
                  builderOtherOptions('Dein Profil', icons: Icons.person),
                  builderOtherOptions('Absenzen',
                      icons: Icons.markunread_sharp),
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
