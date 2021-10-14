import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class User {
  final int id;
  final String username;
  final String password;
  final String url;
  Map<String, dynamic> _userData = {};

  User(
      {@required required this.id,
      @required required this.username,
      @required required this.password,
      @required required this.url});

//Hier wird der Kanal zwischen Flutter und dem Nativen Code aufgebaut -> Java und Swift
  Future<Map<String, dynamic>> getUserData() async {
    const platform = MethodChannel('nesa_app/get_all_user_data');
    
    try {
      Map<String, dynamic> userData =
          await platform.invokeMethod('getUserData', [username, password, url]);
      _userData = userData;
    } on PlatformException catch (error) {
      print(error);
    }

    return _userData;
  }
}
