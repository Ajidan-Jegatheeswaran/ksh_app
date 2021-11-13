import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/models/web_scraper_nesa.dart';
import 'package:ksh_app/screens/my_account_screen.dart';
import 'package:ksh_app/widgets/bottom_navigation_bar_widget.dart';
import 'package:ksh_app/widgets/list_tile_information_widget.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  Map<String, dynamic> userMarks = {};
  String userSaldo = '';
  
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

    return Scaffold(
      bottomNavigationBar: BottomNavigatioinBarWidget(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushReplacementNamed(MyAccountScreen.routeName), //TODO: Verlinkung zum ProfilScreen()
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
              margin: EdgeInsets.only(bottom: mediaQuery.height * 0.013),
            ),
            ListTileInformationWidget(
              shownDataEnum.saldo,
            ),
            ListTileInformationWidget(
              shownDataEnum.openAbsence,
            ),
            ListTileInformationWidget(
              shownDataEnum.testDate,
            ),
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
