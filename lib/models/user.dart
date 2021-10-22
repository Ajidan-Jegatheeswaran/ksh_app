import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:ksh_app/models/web_scraper_nesa.dart';
import 'package:web_scraper/web_scraper.dart';

class User implements ChangeNotifier{
  String username = '';
  String password = '';
  String host = '';
  var webScraperNesa;

  User();

  set setUsername(String username) {
    username = username;
  }

  set setPassword(String password) {
    password = password;
  }

  set setHost(String host) {
    host = host;
  }

  set setWebScraper(WebScraperNesa webScraper) {
    webScraperNesa = webScraper;
  }

  String get getUsername {
    return username;
  }

  String get getPassword {
    return password;
  }

  String get getHost {
    return host;
  }

  WebScraperNesa get getWebScraper {
    return webScraperNesa;
  }

  @override
  void addListener(VoidCallback listener) {
    // TODO: implement addListener
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  // TODO: implement hasListeners
  bool get hasListeners => throw UnimplementedError();

  @override
  void notifyListeners() {
    // TODO: implement notifyListeners
  }

  @override
  void removeListener(VoidCallback listener) {
    // TODO: implement removeListener
  }
}
