import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';

import 'package:ksh_app/models/web_scraper_nesa.dart';
import 'package:path_provider/path_provider.dart';

enum requiredFile {
  userLogin,
  userDashboard,
  userMarks,
  userAbsence,
  userTests,
  userHost,
  userImage,
  userInformation,
  userDuoMarks
}

class User {
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

  //Saldo wird berechnet
  static String saldo(Map<String, dynamic> userMarks) {
    List<double> noten = [];
    double saldo = 0;

    for (dynamic i in userMarks.values) {
      String stringMark =
          i.toString().split(',')[1].split(':')[1].replaceAll(' ', '');
      if (stringMark == '--') {
        continue;
      }

      print('keys');
      print(i.toString());
      double doubleNote = double.parse(stringMark);
      noten.add(doubleNote);
    }
    print('Noten Saldo Noten');
    print(noten);

    for (double mark in noten) {
      double resMarkSaldo = mark - 4;
      if (resMarkSaldo == 0) {
        continue;
      }
      if (resMarkSaldo > 0) {
        while (resMarkSaldo >= 1) {
          resMarkSaldo = resMarkSaldo - 1;
          saldo += 1;
        }
        while (resMarkSaldo >= 0.5) {
          resMarkSaldo = resMarkSaldo - 0.5;
          saldo += 0.5;
        }
        if (resMarkSaldo >= 0.25) {
          resMarkSaldo = 0;
          saldo += 0.5;
        } else if (resMarkSaldo < 0.25) {
          continue;
        } else {
          throw Exception(); //todo: Exception
        }
      } else if (resMarkSaldo < 0) {
        resMarkSaldo = -resMarkSaldo;
        if (resMarkSaldo > 0) {
          while (resMarkSaldo >= 1) {
            resMarkSaldo = resMarkSaldo - 1;
            saldo -= 2;
          }
          while (resMarkSaldo >= 0.5) {
            resMarkSaldo = resMarkSaldo - 0.5;
            saldo -= 1;
          }
          if (resMarkSaldo >= 0.25) {
            resMarkSaldo = 0;
            saldo -= 1;
          } else if (resMarkSaldo < 0.25) {
            continue;
          } else {
            throw Exception(); //todo: Exception
          }
        }
      } else {
        throw Exception(); //todo: Exception
      }
    }
    return saldo.toString();
  }

  //Daten Verarbeitung -> Verwalten der Daten

  static Future<File> _getFile(Enum data) async {
    String fileName = '';
    File file;

    Directory directory = await getApplicationDocumentsDirectory();
    switch (data) {
      case requiredFile.userLogin:
        fileName = 'user_data.json';
        break;
      case requiredFile.userMarks:
        fileName = 'user_marks.json';
        break;
      case requiredFile.userDashboard:
        fileName = 'user_dashbaord.json';
        break;
      case requiredFile.userHost:
        fileName = 'user_host.json';
        break;
      case requiredFile.userImage:
        fileName = 'user_image.json';
        break;
      case requiredFile.userInformation:
        fileName = 'user_information.json';
        break;
      case requiredFile.userDuoMarks:
        fileName = 'user_duo_marks.json';
        break;
      default:
        throw Exception('File Path does not exist');
    }
    file = File(directory.path + '/' + fileName);
    if (!file.existsSync()) {
      file.createSync();
    }
    return file;
  }

  static Future<void> writeInToFile(
      Map<String, dynamic> information, Enum fileEnum) async {
    File file = await _getFile(fileEnum);
    if (file.existsSync()) {
      file.deleteSync();
      file.createSync();
    }
    file.writeAsStringSync(convert.jsonEncode(information));
  }

  static Future<Map<String, dynamic>> readFile(Enum fileEnum) async {
    File file = await _getFile(fileEnum);
    if (!file.existsSync()) {
      throw Exception('File does not Exist'); //todo: Exception
    }
    Map<String, dynamic> data = convert.jsonDecode(file.readAsStringSync());
    return data;
  }

  static Future<bool> getUserData(WebScraperNesa webScraperNesa) async {
    //Login Daten werden beschafft
    Map<String, dynamic> _userData =
        await User.readFile(requiredFile.userLogin);
    //User wird in Nesa eingeloggt
    webScraperNesa = WebScraperNesa(
        username: _userData['username'],
        password: _userData['password'],
        host: _userData['host']);
    await webScraperNesa.login();
    print('Hat es Funktioniert?: ' + webScraperNesa.isLogin().toString());

    //Noten werden verarbeitet
    Map<String, dynamic> userMarks = await webScraperNesa.getMarksData();
    await User.writeInToFile(userMarks, requiredFile.userMarks);

    //Dashboard Informationen
    Map<String, dynamic> userDashboard = {};
    userDashboard['saldo'] = saldo(userMarks);
    userDashboard['openAbsence'] = '0'; //todo:
    userDashboard['nextTestDate'] = '03.12.2021'; //todo:
    await User.writeInToFile(userDashboard, requiredFile.userDashboard);

    //User Informationen von der Startseite
    Map<String, dynamic> userInformation =
        await webScraperNesa.getHomeData(HomePageInfo.information);
    if (userInformation == {}) {
      throw Exception();
    }
    await User.writeInToFile(userInformation, requiredFile.userInformation);
    //Image Informationen
    /*
    Map<String,dynamic> userImage = {};
    
    String imagePath=await webScraperNesa.getUserImageNetworkPath();
    userImage['profilePicture'] = imagePath;
    print('UserImage');
    print(userImage);
    User.writeInToFile(userImage, requiredFile.userImage);
    */

    return webScraperNesa.isLogin();
  }
}
