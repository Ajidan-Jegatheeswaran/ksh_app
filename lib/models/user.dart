// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';

import 'package:ksh_app/models/web_scraper_nesa.dart';
import 'package:path_provider/path_provider.dart';

//Das sind Enums, um die Ordner in den die Daten gespeichert werden einfacher zu unterscheiden
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
  userAllMarks,
  userNewMarks,
  userOpenAbsences,
  userNotRelevantMarks
}

class User {
  String username = '';
  String password = '';
  String host = '';
  var webScraperNesa;

  static List<double> allMarks = [];

  User();

  //Setter und Getter von Variblen in dieser Klasse
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

  static double round(double mark) {
    double _roundedMark = 0;
    while (mark >= 1) {
      mark = mark - 1;
      _roundedMark++;
    }
    if (mark >= 0.75) {
      _roundedMark++;
    } else if (mark >= 0.25 && mark < 0.75) {
      _roundedMark = _roundedMark + 0.5;
    }
    return _roundedMark;
  }

  static Future<List<String>> saldo(Map<String, dynamic> userMarks) async {
    //Listen in den die Algorithmen die einzelnen Fächer einteilen
    List<Map<String, dynamic>> normalMarks = [];
    List<Map<String, dynamic>> duoMarks = [];

    //Algorithmus: Nichtrelevante Noten aussortieren und Einteilung in duoMarks und normalMarks
    for (var item in userMarks.entries.toList()) {
      String key = item.key;
      Map<String, dynamic> value = Map<String, dynamic>.from(item.value);
      Map<String, dynamic> entrie = {key: value};

      bool wert = false;
      bool wert2 = false;
      try {
        wert = value['relevant'];
      } catch (e) {
        wert = false;
      }
      try {
        wert2 = value['duoMark'];
      } catch (e) {
        wert2 = false;
      }

      if (wert) {
        continue;
      } else if (wert2) {
        duoMarks.add(entrie);
      } else {
        normalMarks.add(entrie);
      }
    }

    //TODO: Falls keine Noten vorhanden sind, soll es "--" durch 0 ersetzen. Eine andere Variante wäre es das später bei den berechnungen zu behandeln, indem man alle, die die Note "--" haben sollen nicht behandelt werden.

    //DuoMarks Partner finden: 1. Fach wird angeschaut duoPartner extrahiert, Note in gespeichert, duoPartner gefunden und dessen Note speichern.

    //Speicher
    Map<String, List<double>> _cacheDuoMarks = {};
    List<String> duoPartnerAlreadyMentioned = [];
    bool duoPartnerAlreadyMentionedBool = false;

    for (Map<String, dynamic> item in duoMarks) {
      Map<String, dynamic> _value = item.values.first;
      String key1 = item.keys.first;
      String _duoPartner = _value['duoPartner'];

      //Überprüfen, ob der Duo Partner des Faches schon in gespeichert wurde

      for (var entrie in _cacheDuoMarks.entries) {
        String key = entrie.key;
        List<double> marks = entrie.value;

        if (_duoPartner.contains(key)) {
          marks[1] = double.parse(_value['Note']);
          _cacheDuoMarks[key] = marks;
          duoPartnerAlreadyMentionedBool = true;
        }
      }
      if(duoPartnerAlreadyMentionedBool){
          duoPartnerAlreadyMentionedBool = false;
          continue;
        }

      //This is the new one.
      /*
      for (var entrie in _cacheDuoMarks.entries.toList()) {
        String key = entrie.key;
        for(String str in duoPartnerAlreadyMentioned){
          if(str.contains(key)){
            duoPartnerAlreadyMentionedBool = true;
          }
        }
        if(duoPartnerAlreadyMentionedBool){
          duoPartnerAlreadyMentionedBool = false;
          continue;
        }
        if (key.contains(_duoPartner)) {
          List<double> _marks = entrie.value;
          if (_value['Note'] == '--') {
            _marks[1] = 0.0;
          } else {
            _marks[1] = double.parse(_value['Note']);
          }

          _cacheDuoMarks[key] = _marks;
        }
      }*/

      //Wenn Duo Partner des Faches noch nicht gespeichert
      double _mark = 0;
      String _subject = _value['Fach'];
      if (_value['Note'].toString() == '--') {
        _mark = 0.0;
      } else {
        _mark = double.parse(_value['Note']);
        duoPartnerAlreadyMentioned.add(_value['duoPartner']);
      }

      _cacheDuoMarks[_subject] = [_mark, 0];
    }

    List<double> allMarks = [];

    //Duo Noten runden und dann zusammenrechnen.
    for (var item in _cacheDuoMarks.values) {
      List<double> _marks = item;
      List<double> _roundedMarks = [];
      for (double mark in _marks) {
        double _markOnes = 0;
        while (mark >= 1) {
          mark = mark - 1;
          _markOnes++;
        }
        if (mark >= 0.75) {
          _markOnes++;
        } else if (mark >= 0.25 && mark < 0.75) {
          _markOnes = _markOnes + 0.5;
        }
        _roundedMarks.add(_markOnes);
      }

      if (_roundedMarks.length == 2) {
        double mrk1 = _roundedMarks[0];
        double mrk2 = _roundedMarks[1];
        if (mrk1 == 0 || mrk2 == 0) {
          double res = mrk1 + mrk2;
          if (res != 0) {
            allMarks.add(res);
          }
        } else {
          double sum = mrk1 + mrk2;
          double res = sum / 2;
          if (res != 0) {
            allMarks.add(res);
          }
        }
      } else {
        throw Exception('Es hat in einer DuoNote mehr als 2 Noten');
      }
    }

    //Noten von Normalen Noten in eine Liste packen gerundet

    for (var i in normalMarks) {
      Map<String, dynamic> fach = Map<String, dynamic>.from(i);
      Map<String, dynamic> value = Map<String, dynamic>.from(fach.values.first);
      if (value['Note'] == '--') {
        continue;
      }

      double mark = double.parse(value['Note']);

      double roundedMark = User.round(mark);
      if (roundedMark != 0) {
        allMarks.add(roundedMark);
      }
    }
    double saldo = 0;
    //Plus und Minus Punkte von den Noten in einen gemeinsamen Saldo verrechnen und wiedergeben
    for (double _mark in allMarks) {
      if (_mark == 4) {
        continue;
      } else if (_mark > 4) {
        _mark = _mark - 4;
        while (_mark >= 1) {
          _mark = _mark - 1;
          saldo += 1;
        }
        if (_mark >= 0.75) {
          saldo += 1;
        } else if (_mark >= 0.25 && _mark < 0.75) {
          saldo += 0.5;
        } else {
          continue;
        }
      } else {
        _mark = 4 - _mark;
        while (_mark >= 1) {
          _mark = _mark - 1;
          saldo = saldo - 2;
        }
        if (_mark >= 0.75) {
          continue;
        } else if (_mark < 0.75 && _mark >= 0.25) {
          saldo = saldo - 1;
        } else {
          continue;
        }
      }
    }

    //Notendurschnitt
    double sumAllMarks = 0;

    for (double num in allMarks) {
      sumAllMarks += num;
    }
    double notenschnitt = sumAllMarks / allMarks.length;

    return [saldo.toString(), notenschnitt.toString()];
  }

  //Saldo wird berechnet
  /*
  static Future<List<String>> saldo(Map<String, dynamic> userMarks) async {
    //Wichtig: !!!! Diese Funktion ist nicht mehr aktuelle -> saldoTwo
    List<double> noten = [];
    double saldo = 0;

    List<Map<String, dynamic>> normalMarks = [];
    List<Map<String, dynamic>> duoMarks = []; //Every mark it noted one time.
    List<Map<String, double>> duoPartners = [];
    List<Map<double, double>> duoMarks =
        []; //Here comes every mark from subject one and two which later get summeriesed

    for (Map<String, dynamic> i in userMarks.entries.toList()) {
      bool skip = false;

      String key = i.keys.first;
      Map<String, dynamic> value = Map<String, dynamic>.from(i.values.first);

      //Wird überprüft, ob es relevant ist
      if (i['relevant'] == true) {
        continue;
      }
      //Überprüft ob der Duo Parnter des Faches schon einmal genommen wurde.
      for (Map<String, double> duoPartner in duoPartners) {
        String duoPartnerKey = duoPartner.keys.first;
        if (key.contains(duoPartnerKey)) {}
      }

      if (i['duoMark'] == true) {
        duoMarks.add(i);
        String duoPartner = i['duoPartner'];
        double mark = i['Note'];
        Map<String, double> cache = {duoPartner: mark};
        duoPartners.add(cache);

        duoPartners.add(duoPartner);
      } else {
        //Todo:
      }

      //Die einzelnen Duo Noten runden

      //Zusammenrechnen und runden

      //Pluspunkt und Minuspunkte entnehmen

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

    //Hier werden Werte abgezogen bis ein Minimum erreicht wurde. Pro abgezogener Wert wird das beim Saldo einen Wert addiert, was schlussendlich den Notensaldo ergibt.
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
    double notendurchschnitt =
        (_notendurchschnittValue / _counterNotenDurchschnitt);
    if (saldo.toString().startsWith('-')) {
      saldo.toString().replaceAll('-', '');
    }
    return [saldo.toString(), notendurchschnitt.toString()];
  }
  */

  //Daten Verarbeitung -> Verwalten der Daten

  //Diese Methode gibt den gewünschten File zurück, der per Enum gesucht wird
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
        fileName = 'user_all_marks.json';
        break;
      case requiredFile.userNewMarks:
        fileName = 'user_new_marks.json';
        break;
      case requiredFile.userOpenAbsences:
        fileName = 'user_open_absences.json';
        break;
      case requiredFile.userNotRelevantMarks:
        fileName = 'user_not_relevant_marks.json';
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

  //Speichert eine Map in einer JSON Datei
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
    File file = File('');
    try {
      file = await getFile(fileEnum);
    } catch (e) {
      return {};
    }
    if (!file.existsSync()) {
      return {};
    }

    if (file.readAsStringSync() == Null ||
        file.readAsStringSync() == '' ||
        file.readAsStringSync() == '{}') {
      return {};
    }

    Map<String, dynamic> data = convert.jsonDecode(file.readAsStringSync());
    print('Schreiben der Datei beendet...');
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

    //Einzelnoten werden geladen
    Map<String, dynamic> userAllMarks = await webScraperNesa.getAllMarks();

    await User.writeInToFile(userAllMarks, requiredFile.userAllMarks);
    //Noten werden verarbeitet
    Map<String, dynamic> userMarks = await webScraperNesa.getMarksData();

    //Nicht Relevante Noten werden angewendet
    Map<String, dynamic> userNotRelevantMarks =
        await User.readFile(requiredFile.userNotRelevantMarks);
    List<String> userNotRelevantMarksTitles =
        userNotRelevantMarks.keys.toList();

    for (var i = 0; i < userNotRelevantMarksTitles.length; i++) {
      for (var item in userMarks.entries.toList()) {
        Map<String, dynamic> res = Map<String, dynamic>.from(item.value);
        if (res == Null) {
          continue;
        }
        String s = res['Fach'];
        if (userNotRelevantMarksTitles[i].contains(s)) {
          String title = item.key;
          res['relevant'] = true;
          userMarks[title] = res;
        }
      }
    }

    //Duo Noten werden angewendet
    //Schauen, ob im Key Beispielweise "EnglischFranzösisch" ein Name eines Faches steckt. Falls ja wird eine
    //zweiter Algorhythmus seinen Partner finden.
    Map<String, dynamic> duoMarks =
        await User.readFile(requiredFile.userDuoMarks);

    for (String str in duoMarks.keys) {
      for (var item in userMarks.entries.toList()) {
        String key = item.key;
        Map<String, dynamic> value = Map<String, dynamic>.from(item.value);

        if (str.contains(value['Fach'])) {
          value['duoMark'] = true;
          value['duoPartner'] = str.replaceAll(key, '');
          userMarks[key] = value;
        }
      }
    }

    await User.writeInToFile(userMarks, requiredFile.userMarks);

    //User Informationen von der Startseite
    Map<String, dynamic> userNewMarks =
        await webScraperNesa.getHomeData(HomePageInfo.newMarks);
    Map<String, dynamic> userInformation =
        await webScraperNesa.getHomeData(HomePageInfo.information);
    Map<String, dynamic> userOpenAbsences =
        await webScraperNesa.getHomeData(HomePageInfo.openAbsence);
    if (userInformation == {}) {
      throw Exception();
    }
    await User.writeInToFile(userInformation, requiredFile.userInformation);
    await User.writeInToFile(userNewMarks, requiredFile.userNewMarks);
    await User.writeInToFile(userOpenAbsences, requiredFile.userOpenAbsences);

    //Dashboard Informationen
    Map<String, dynamic> userDashboard = {};
    userDashboard['saldo'] = await saldo(userMarks);
    userDashboard['openAbsence'] = userOpenAbsences.length.toString(); //todo:
    userDashboard['notenschnitt'] = await saldo(userMarks); //todo:
    if (userDashboard['openAbsence'] == '') {
      userDashboard['openAbsence'] = 0.toString();
    }
    await User.writeInToFile(userDashboard, requiredFile.userDashboard);

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

  static Future<void> refreshSaldo() async {
    Map<String,dynamic> userMarks = await User.readFile(requiredFile.userMarks);

    //Dashboard Informationen
      Map<String, dynamic> userDashboard =
          await User.readFile(requiredFile.userDashboard);
      userDashboard['saldo'] = await saldo(userMarks);
    await User.writeInToFile(userMarks, requiredFile.userMarks);
  }
}
