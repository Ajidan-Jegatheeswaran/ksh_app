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
}
