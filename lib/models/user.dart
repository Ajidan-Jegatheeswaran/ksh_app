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
  userDuoMarks,
  userAllMarks
}

class User {
  String username = '';
  String password = '';
  String host = '';
  var webScraperNesa;

  static List<double> allMarks = [];

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
  static Future<List<String>> saldo(Map<String, dynamic> userMarks) async {
    List<double> noten = [];
    double saldo = 0;

    Map<String, dynamic> _userDuoMarks =
        await User.readFile(requiredFile.userDuoMarks);

    List<String> alreadyDoneDuoMarks = [];

    for (Map<String, dynamic> i in userMarks.values) {
      /*
      if (i['relevant'] == true) {
        continue;
      }
      for (String item in _userDuoMarks.keys) {
        if (item.contains(i['Fach'])) {
          print('Duo Noten im Saldo...');
          print(i['Fach']);

          double sum = double.parse(_userDuoMarks[item].keys.first['Note']) +
              double.parse(_userDuoMarks[item].values.first['Note']);
          print('Saldo Duo Note Summe = ' + sum.toString());
          double notenschnitt = sum / 2;
          print('Notenschnitt = ' + notenschnitt.toString());
        }else{
          print('Das ist keine Duo Note: '+ i['Fach']);
        }
      }
      */

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

    allMarks = noten;

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

    double _notendurchschnittValue = 0;
    int _counterNotenDurchschnitt = 0;
    print('AllMarks');
    print(allMarks);
    for (double item in allMarks) {
      _notendurchschnittValue += item;

      _counterNotenDurchschnitt++;
    }
    print('Notenschnitt');
    print(_notendurchschnittValue);
    print(_counterNotenDurchschnitt);
    print((_notendurchschnittValue / _counterNotenDurchschnitt).toString());
    double notendurchschnitt = (_notendurchschnittValue / _counterNotenDurchschnitt);
    return [saldo.toString(), notendurchschnitt.toString()];
  }

  //Daten Verarbeitung -> Verwalten der Daten

  static Future<File> getFile(Enum data) async {
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
      case requiredFile.userAllMarks:
        fileName = 'all_marks.json';
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
    File file = await getFile(fileEnum);
    if (file.existsSync()) {
      file.deleteSync();
      file.createSync();
    }
    file.writeAsStringSync(convert.jsonEncode(information));
  }

  static Future<Map<String, dynamic>> readFile(Enum fileEnum) async {
    File file = await getFile(fileEnum);
    if (!file.existsSync()) {
      throw Exception('File does not Exist'); //todo: Exception
    }
    print('ReadFile');
    print(file.readAsStringSync());
    if (file.readAsStringSync() == Null || file.readAsStringSync() == '') {
      return {};
    }
    print('File String');
    print(file.readAsStringSync());
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
    webScraperNesa.getAbsenceData();
    //Noten werden verarbeitet
    Map<String, dynamic> userMarks = await webScraperNesa.getMarksData();
    print('User Marks');
    print(userMarks);
    await User.writeInToFile(userMarks, requiredFile.userMarks);

    
    //Dashboard Informationen
    Map<String, dynamic> userDashboard = {};
    userDashboard['saldo'] = await saldo(userMarks);
    print('Absence Data');
    userDashboard['openAbsence'] = webScraperNesa.openAbsence.replaceAll('\n', ''); //todo:
    userDashboard['notenschnitt'] = await saldo(userMarks); //todo:
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

  //_deleteAppDir() wurde aus StackOverFlow kopiert -> https://stackoverflow.com/questions/62547759/how-to-implement-flutter-clear-user-app-data-and-storage-on-logout
  static Future<void> deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }
}
