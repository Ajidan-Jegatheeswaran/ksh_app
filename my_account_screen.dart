import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/screens/choose_school_screen.dart';
import 'package:ksh_app/screens/duo_noten_screen.dart';
import 'package:ksh_app/screens/not_relevant_marks_screen.dart';
import 'package:ksh_app/widgets/bottom_navigation_bar_widget.dart';
import 'package:ksh_app/widgets/list_tile_information_section_widget.dart';
import 'package:ksh_app/widgets/list_tile_setting_widget.dart';

class MyAccountScreen extends StatelessWidget {
  static const routeName = '/my-account';

  void logout() {}

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    // ignore: prefer_const_literals_to_create_immutables
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Mein Konto'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                User.deleteAppDir();

                Navigator.of(context)
                    .pushNamedAndRemoveUntil(ChooseSchoolScreen.routeName, (Route<dynamic> route) => false);
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
          print(snap.data);
          print(snap);
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                              NotRelevantMarksScreen.routeName)
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: mediaQuery.width - 30,
                  color: Theme.of(context).colorScheme.secondary,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
