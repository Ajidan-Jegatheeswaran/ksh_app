import 'package:flutter/material.dart';
import './screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KSH APP',
      theme: ThemeData(
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
          canvasColor: const Color.fromRGBO(0, 161, 178, 1.0)
      ),
      home: HomeScreen(),
    );
  }
}
