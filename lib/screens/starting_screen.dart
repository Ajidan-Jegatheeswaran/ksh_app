import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ksh_app/screens/choose_school_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../models/user.dart';
import '../models/web_scraper_nesa.dart';
import 'home_screen.dart';

class StartingScreen extends StatelessWidget {
  const StartingScreen({Key? key}) : super(key: key);
  static const routeName = '/starting-screen';

  Future<bool> tryLogin(ctx) async {
    try{
    Map<String, dynamic> _userData =
        await User.readFile(requiredFile.userLogin);
    if (_userData != {}) {
      WebScraperNesa webScraperNesa = WebScraperNesa(
          username: _userData['username'],
          password: _userData['password'],
          host: _userData['host']);
          print(_userData['username']);
          print(_userData['password']);
          print(_userData['host']);
      try {
        await webScraperNesa.login();
      } on SocketException {
        throw Exception(
            'Probleme mit der Interverbindung'); //TODO: Internetverbindung
      }

      if (webScraperNesa.isLogin()) {
        await User.getUserData(webScraperNesa);

        Navigator.of(ctx).pushNamedAndRemoveUntil(
            HomeScreen.routeName, ModalRoute.withName(HomeScreen.routeName));
      } else {
        
      }
    }
    }catch(e){
      Navigator.of(ctx).pushNamedAndRemoveUntil(
            ChooseSchoolScreen.routeName, ModalRoute.withName(ChooseSchoolScreen.routeName));
    }
    return false;
  }

  Widget loadingScreen(BuildContext ctx) {
    tryLogin(ctx);

    return Container(
      color: Theme.of(ctx).backgroundColor,
      child: Center(
        child: LoadingAnimationWidget.horizontalRotatingDots(
          color: Colors.white,
          size: 200,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loadingScreen(context);
  }
}
