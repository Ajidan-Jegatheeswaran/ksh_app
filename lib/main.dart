import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/models/web_scraper_nesa.dart';
import 'package:ksh_app/screens/choose_school_screen.dart';
import 'package:ksh_app/screens/detail_noten_screen.dart';
import 'package:ksh_app/screens/home_screen.dart';
import 'package:ksh_app/screens/my_account_screen.dart';
import 'package:ksh_app/screens/not_relevant_marks_screen.dart';
import 'package:ksh_app/screens/duo_noten_screen.dart';
import 'package:ksh_app/widgets/duo_note_erstellen_select_widget.dart';
import 'package:path_provider/path_provider.dart';

import './screens/login_screen.dart';
import 'screens/noten_screen.dart';

void main() async {
  runApp(MyApp());
  /*
  WebScraperNesa webScraperNesa = WebScraperNesa(
      username: 'jon.stojkaj', password: '21Jonmalone?', host: 'ksh');

  /*
  WebScraperNesa webScraperNesa = WebScraperNesa(
      username: 'haesan.ashokarasan', password: 'Haesan2021.', host: 'ksh');
  */

  await webScraperNesa.login();
  
  await User.getUserData(webScraperNesa);
*/
  //await webScraperNesa.getAllMark();
  //print(await webScraperNesa.getCalendarData());
  //await webScraperNesa.getAllMark();

  /*
  var login = LoginScreen();
  
  bool isLogin = false;
  try {
    File login = await User.getFile(requiredFile.userLogin);
    File host = await User.getFile(requiredFile.userHost);
    if (login.existsSync() && host.existsSync()) {
      Map<String, dynamic> loginData =
          await User.readFile(requiredFile.userLogin);
      Map<String, dynamic> hostData =
          await User.readFile(requiredFile.userHost);
      WebScraperNesa webScraperNesa = WebScraperNesa(
          username: loginData['username'],
          password: loginData['password'],
          host: hostData['subdomain']);
      isLogin = await User.getUserData(webScraperNesa);
    }
  } on Exception {
    runApp(MyApp(false));
  }
  /*
  
  await webScraperNesa.login();
  if (webScraperNesa.isLogin()) {
    print('Eingeloggt...');
  }*/
  //await User.getUserData(webScraperNesa);
  */
  //await User.getUserData(webScraperNesa);

  //debugShowCheckedModeBanner: true;
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KSH APP',
      theme: ThemeData(
        //Farben
        primarySwatch: const MaterialColor(
          0xFF181825,
          <int, Color>{
            50: Color(0xFF181825),
            100: Color(0xFF181825),
            200: Color(0xFF181825),
            300: Color(0xFF181825),
            400: Color(0xFF181825),
            500: Color(0xFF181825),
            600: Color(0xFF181825),
            700: Color(0xFF181825),
            800: Color(0xFF181825),
            900: Color(0xFF181825),
          },
        ),
        colorScheme: ThemeData().colorScheme.copyWith(
              secondary: const MaterialColor(
                0xFF252A34,
                <int, Color>{
                  50: Color(0xFF252A34),
                  100: Color(0xFF252A34),
                  200: Color(0xFF252A34),
                  300: Color(0xFF252A34),
                  400: Color(0xFF252A34),
                  500: Color(0xFF252A34),
                  600: Color(0xFF252A34),
                  700: Color(0xFF252A34),
                  800: Color(0xFF252A34),
                  900: Color(0xFF252A34),
                },
              ),
            ),
        canvasColor: const Color.fromRGBO(0, 161, 178, 1.0),

        //Text Konfiguration
        textTheme: const TextTheme(
          headline6: TextStyle(color: Colors.white),
        ),
      ),
      home: ChooseSchoolScreen(),
      routes: {
        LoginScreen.routeName: (ctx) => LoginScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
        NotenScreen.routeName: (ctx) => NotenScreen(),
        MyAccountScreen.routeName: (ctx) => MyAccountScreen(),
        ChooseSchoolScreen.routeName: (ctx) => ChooseSchoolScreen(),
        DuoNotenScreen.routeName: (ctx) => DuoNotenScreen(),
        DetailNotenScreen.routeName: (ctx) => DetailNotenScreen(),
        NotRelevantMarksScreen.routeName: (ctx) => NotRelevantMarksScreen()
      },
    );
  }
}
