import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/models/web_scraper_nesa.dart';
import 'package:ksh_app/screens/choose_school_screen.dart';
import 'package:ksh_app/screens/duo_noten_screen.dart';
import 'package:ksh_app/screens/home_screen.dart';
import 'package:ksh_app/screens/not_relevant_marks_screen.dart';
import 'package:ksh_app/screens/starting_screen.dart';
import 'package:ksh_app/widgets/bottom_navigation_bar_widget.dart';
import 'package:ksh_app/widgets/list_tile_information_section_widget.dart';
import 'package:ksh_app/widgets/list_tile_setting_widget.dart';

//Das ist der Einstellungsbildschirm bzw. der Mein Konto Bildschirm, der Nutzer Informationen anzeigt und Einstellung Möglichkeiten in Bezug auf den Notensaldo bietet.
class MyAccountScreen extends StatelessWidget {
  static const routeName = '/my-account';

  void logout() {}

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    // ignore: prefer_const_literals_to_create_immutables
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: const Text('Mein Konto'),
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            IconButton(
                onPressed: () {
                  //Alle Daten löschen

                  List<Enum> dataFiles = [
                    requiredFile.userLogin,
                    requiredFile.userDashboard,
                    requiredFile.userMarks,
                    requiredFile.userHost,
                    requiredFile.userImage,
                    requiredFile.userInformation,
                    requiredFile.userDuoMarks,
                    requiredFile.userAllMarks,
                    requiredFile.userNewMarks,
                    requiredFile.userOpenAbsences,
                    requiredFile.userNotRelevantMarks
                  ];
                  User.deleteAppDir();
                  for (Enum e in dataFiles) {
                    User.writeInToFile({}, e);
                  }

                  Navigator.of(context).pushNamedAndRemoveUntil(
                      StartingScreen.routeName,
                      (Route<dynamic> route) => false);
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        bottomNavigationBar: BottomNavigatioinBarWidget(),
        body: FutureBuilder(
          future: User.readFile(requiredFile.userInformation),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: Colors.white,
              );
            }

            Map<String, dynamic> _map = snap.data as Map<String, dynamic>;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Center(
                    child: CircleAvatar(
                      //backgroundImage: AssetImage('assets/images/user_profile.jpg'),
                      radius: 60,
                      backgroundColor: Colors.blueGrey,
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    _map['Name'],
                    style: TextStyle(color: Colors.white),
                    textScaleFactor: 1.9,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: mediaQuery.width - 30,
                    color: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    child: Column(
                      children: [
                        const Text(
                          'Einstellungen',
                          style: TextStyle(color: Colors.white),
                          textScaleFactor: 1.5,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Column(
                          children: [
                            ListTileForSettings(
                                'Duo Noten', DuoNotenScreen.routeName),
                            ListTileForSettings('Nicht relevante Noten',
                                NotRelevantMarksScreen.routeName),
                           // ListTileForSettings(
                           //     'Bug melden', DuoNotenScreen.routeName)
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: mediaQuery.width - 30,
                    color: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    child: Column(
                      children: [
                        const Text(
                          'Deine Daten',
                          style: TextStyle(color: Colors.white),
                          textScaleFactor: 1.5,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _map.length,
                          itemBuilder: (ctx, index) {
                            if (index == 0) {
                              return const SizedBox(
                                height: 0,
                                width: 0,
                              );
                            }
                            return Column(
                              children: [
                                ListTileInformationSectionWidget(
                                    _map.keys.toList()[index],
                                    _map.values.toList()[index]),
                                const SizedBox(
                                  height: 4,
                                )
                              ],
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ListTileForSettings extends StatelessWidget {
  final title;
  var navigator;

  ListTileForSettings(this.title, this.navigator);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).primaryColor,
          child: ListTile(
            onTap: () {
              Navigator.pushNamed(context, navigator);
            },
            title: Text(
              title,
              style: const TextStyle(color: Colors.white),
              textScaleFactor: 1.1,
            ),
            trailing: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, navigator);
                },
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                )),
          ),
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }
}
