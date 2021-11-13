import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ksh_app/widgets/list_tile_information_section_widget.dart';

class MyAccountScreen extends StatelessWidget {
  static const routeName = '/my-account';

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    // ignore: prefer_const_literals_to_create_immutables
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Mein Konto'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
        builder: (ctx, snap) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Center(
                  child: CircleAvatar(
                    //backgroundImage: AssetImage('assets/images/user_profile.jpg'),
                    radius: 90,
                    backgroundColor: Colors.blueGrey,
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Felix Mustermann',
                  style: TextStyle(color: Colors.white),
                  textScaleFactor: 1.9,
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  width: mediaQuery.width - 30,
                  color: Theme.of(context).colorScheme.secondary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      const Text(
                        'Deine Daten',
                        style: TextStyle(color: Colors.white),
                        textScaleFactor: 1.5,
                      ),
                      //Flexible(child: ListView.builder(itemBuilder: ListTileInformationSectionWidget()))
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
