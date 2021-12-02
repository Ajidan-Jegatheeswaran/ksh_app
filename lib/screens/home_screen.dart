import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/models/web_scraper_nesa.dart';
import 'package:ksh_app/screens/my_account_screen.dart';
import 'package:ksh_app/screens/duo_noten_screen.dart';
import 'package:ksh_app/widgets/bottom_navigation_bar_widget.dart';
import 'package:ksh_app/widgets/list_tile_information_widget.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  Map<String, dynamic> userMarks = {};
  String userSaldo = '';

  Map<String, dynamic> newMarks = {};
  Map<String, dynamic> openAbsences = {};

  //ReadUserData Variabeln
  // ignore: prefer_final_fields

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

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
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Icon(
                icons,
                size: mediaQuery.width * 0.3 * 0.7,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            )
          ],
        ),
      );
    }

    Future<void> getData() async {
      newMarks = await User.readFile(requiredFile.userNewMarks);
      openAbsences = await User.readFile((requiredFile.userOpenAbsences));
      print('NewMarks Home');
      print(newMarks);
      print('Open Absences Home');
      print(openAbsences);
    }

    return Scaffold(
      bottomNavigationBar: BottomNavigatioinBarWidget(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushReplacementNamed(
                MyAccountScreen
                    .routeName), //TODO: Verlinkung zum ProfilScreen()
          ),
        ],
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (ctx, snap) {
          print('NewMarks');
          print(newMarks);

          return SingleChildScrollView(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 15),
            child: Column(
              children: [
                /*
              Container(
                color: Theme.of(context).colorScheme.secondary,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.25,
                margin: EdgeInsets.only(bottom: mediaQuery.height * 0.013),
              ), */
                ListTileInformationWidget(
                    shownDataEnum.saldo, const Icon(Icons.school_outlined)),
                ListTileInformationWidget(shownDataEnum.openAbsence,
                    const Icon(Icons.person_off_outlined)),
                ListTileInformationWidget(shownDataEnum.notenschnitt,
                    const Icon(Icons.article_outlined)),
                SizedBox(
                  height: mediaQuery.height * 0.03,
                ),
                const SizedBox(
                  height: 15,
                ),
                newMarks.length != 0
                    ? Container(
                        padding: EdgeInsets.all(15),
                        color: Theme.of(context).colorScheme.secondary,
                        width: MediaQuery.of(context).size.width,
                        margin:
                            EdgeInsets.only(bottom: mediaQuery.height * 0.013),
                        child: Column(
                          children: [
                            const Center(
                              child: Text(
                                'Neue Noten',
                                style: TextStyle(color: Colors.white),
                                textScaleFactor: 1.2,
                              ),
                            ),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: newMarks.length,
                              itemBuilder: (ctx, index) {
                                return Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 15),
                                      width: mediaQuery.width - 60,
                                      color: Theme.of(context).primaryColor,
                                      child: ListTile(
                                        title: Text(
                                            newMarks[index.toString()]
                                                ['testName'],
                                            style:
                                                TextStyle(color: Colors.white)),
                                        subtitle: Text(
                                            newMarks[index.toString()]['title'],
                                            style:
                                                TextStyle(color: Colors.white)),
                                        trailing: Text(
                                          newMarks[index.toString()]
                                              ['valuation'],
                                          style: const TextStyle(
                                              color: Colors.white),
                                          textScaleFactor: 1.3,
                                        ),
                                      ),
                                    ),
                                    newMarks.length > 1
                                        ? const SizedBox(
                                            height: 0,
                                          )
                                        : const SizedBox(
                                            height: 0,
                                            width: 0,
                                          )
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      ),
                //Absenzen

                !(openAbsences.length == 0 || openAbsences == Null)
                    ? Container(
                        padding: EdgeInsets.all(15),
                        color: Theme.of(context).colorScheme.secondary,
                        width: MediaQuery.of(context).size.width,
                        margin:
                            EdgeInsets.only(bottom: mediaQuery.height * 0.013),
                        child: Column(
                          children: [
                            const Center(
                              child: Text(
                                'Offene Absenzen',
                                style: TextStyle(color: Colors.white),
                                textScaleFactor: 1.2,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),  
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: openAbsences.length,
                              itemBuilder: (ctx, index) {
                                return Column(
                                  children: [
                                    Container(
                                      width: mediaQuery.width - 60,
                                      color: Theme.of(context).primaryColor,
                                      child: ListTile(
                                        title: Text(
                                          openAbsences[index.toString()]![
                                              'from'],
                                          style: TextStyle(color: Colors.white),
                                          textScaleFactor: 0.9,
                                        ),
                                        subtitle: Text(
                                          openAbsences[index.toString()]!['to'],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        trailing: Text(
                                          openAbsences[index.toString()]![
                                              'deadline'],
                                          style: const TextStyle(
                                              color: Colors.white),
                                          textScaleFactor: 1,
                                        ),
                                      ),
                                    ),
                                    openAbsences.length > 1
                                        ? const SizedBox(
                                            height: 15,
                                          )
                                        : const SizedBox(
                                            height: 0,
                                            width: 0,
                                          )
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    /*  
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
                        builderOtherOptions('Kalender',
                            icons: Icons.calendar_today),
                        builderOtherOptions('Dein Profil', icons: Icons.person),
                        builderOtherOptions('Absenzen',
                            icons: Icons.markunread_sharp),
                        builderOtherOptions('Absenzen', icons: Icons.ac_unit),
                        builderOtherOptions('Absenzen', icons: Icons.ac_unit),
                        builderOtherOptions('Absenzen', icons: Icons.ac_unit),
                      ],
                    ),
                  )*/
                    : Container(height: 0, width: 0)
              ],
            ),
          );
        },
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
