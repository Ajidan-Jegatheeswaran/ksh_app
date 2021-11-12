import 'dart:ui';

import 'package:flutter/material.dart';

class MyAccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    // ignore: prefer_const_literals_to_create_immutables
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dein Konto'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Center(
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/user_profile.jpg'),
                radius: 90,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Felix Mustermann',
              style: TextStyle(color: Colors.white),
              textScaleFactor: 2,
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              width: mediaQuery.width - 30,
              color: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: const [
                  Text(
                    'Deine Daten',
                    style: TextStyle(color: Colors.white),
                    textScaleFactor: 1.5,
                  ),
                  ListTile(
                    
                    title: Text(
                      'Nationalität',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text('Schweiz'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
