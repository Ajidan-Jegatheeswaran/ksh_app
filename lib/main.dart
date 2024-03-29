import 'package:flutter/material.dart';
import 'package:ksh_app/screens/bug_screen.dart';
import 'package:ksh_app/screens/choose_school_screen.dart';
import 'package:ksh_app/screens/detail_noten_screen.dart';
import 'package:ksh_app/screens/home_screen.dart';
import 'package:ksh_app/screens/my_account_screen.dart';
import 'package:ksh_app/screens/not_relevant_marks_screen.dart';
import 'package:ksh_app/screens/duo_noten_screen.dart';
import 'package:ksh_app/screens/starting_screen.dart';

import './screens/login_screen.dart';
import 'screens/noten_screen.dart';

void main() async {
  runApp(MyApp()); //Hier wird alles gestartet
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
      home: const StartingScreen(), // Der erste Bildschirm
      routes: {
        //Das sind die Navigationsmöglichkeiten
        StartingScreen.routeName: (ctx) => const StartingScreen(),
        LoginScreen.routeName: (ctx) => LoginScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
        NotenScreen.routeName: (ctx) => NotenScreen(),
        MyAccountScreen.routeName: (ctx) => MyAccountScreen(),
        ChooseSchoolScreen.routeName: (ctx) => ChooseSchoolScreen(),
        DuoNotenScreen.routeName: (ctx) => DuoNotenScreen(),
        DetailNotenScreen.routeName: (ctx) => DetailNotenScreen(),
        NotRelevantMarksScreen.routeName: (ctx) => NotRelevantMarksScreen(),
        BugScreen.routeName: (ctx)=> BugScreen()
      },
    );
  }
}
