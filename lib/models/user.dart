// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:ksh_app/models/web_scraper_nesa.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    //Nicht relevante Daten anwenden
    //Laden der der Nichtrelevante Noten
    Map<String, bool> userNotRelevantMarks = await User.readNotRelevantMarks();
    //Liste der mit den boolean erstellen
    List<bool> userNotRelevantMarksBool = userNotRelevantMarks.values.toList();
    //Die userMarks durch iterrieren und diese in die Fächer von userMarks einsetzen unter dem Parameter "relevant"
    for (int i = 0; i < userMarks.length; i++) {
      String keyUserMarks = userMarks.keys.toList()[i];
      Map<String, dynamic> value = userMarks.values.toList()[i];
      value['relevant'] = userNotRelevantMarksBool[i].toString();
      userMarks[keyUserMarks] = value;
    }

    //Duo Noten werden angewendet
    //Schauen, ob im Key Beispielweise "EnglischFranzösisch" ein Name eines Faches steckt. Falls ja wird eine
    //zweiter Algorhythmus seinen Partner finden.
    Map<String, dynamic> duoMarksSecond =
        await User.readFile(requiredFile.userDuoMarks);

    for (String str in duoMarksSecond.keys) {
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

    //Algorithmus: Nichtrelevante Noten aussortieren und Einteilung in duoMarks und normalMarks
    for (var item in userMarks.entries.toList()) {
      String key = item.key;
      Map<String, dynamic> value = Map<String, dynamic>.from(item.value);
      Map<String, dynamic> entrie = {key: value};

      bool wert = false;
      bool wert2 = false;
      try {
        wert = value['relevant'] == 'true' ? true : false;
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
      if (duoPartnerAlreadyMentionedBool) {
        duoPartnerAlreadyMentionedBool = false;
        continue;
      }

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

    //Daten mit SharedPrefs laden

    return data;
  }

  static Future<void> saveNotRelevantMarks(Map<String, bool> settings) async {
    //Mittels Map die richtigen Fächer finden und entsprechende bool einfügen für den Parameter: relevant
    //Aufbau der Map settings:  Map<Fachname, relevant>
    for (int i = 0; i < settings.length; i++) {
      String settingsFachname = settings.keys.toList()[i];
      bool settingsRelevant = settings.values.toList()[i];
      Map<String, dynamic> marks = await User.readFile(requiredFile.userMarks);

      //marks durch iterieren bis man das passende Fach gefunden hat und den Parameter relevant einfügen
      for (int j = 0; j < marks.length; j++) {
        String marksKey = marks.keys.toList()[j];
        Map<String, dynamic> value = marks.values.toList()[j];
        String marksFachname = marks.values.toList()[j]['Fach'];

        if (marksFachname == settingsFachname || marksKey == settingsFachname) {
          value['relevant'] = settingsRelevant;
          marks[marksKey] = value;
        }
      }

      //Die vorgenommenen Einstellungen in userMarks speichern
      await User.writeInToFile(marks, requiredFile.userMarks);

      //Nun sollen die settings auch in userNotRelevantMarks gespeichert werden
      await User.writeInToFile(settings, requiredFile.userNotRelevantMarks);

      //Die Änderungen solen nun auch zur Änderung des Saldos führen
      //Dashboarddaten laden und neue Daten aktualisieren
      Map<String, dynamic> userDashboard =
          await User.readFile(requiredFile.userDashboard);
      userDashboard['saldo'] = await saldo(marks);
      userDashboard['notenschnitt'] = await saldo(marks);
      await User.writeInToFile(userDashboard, requiredFile.userDashboard);
    }
  }

  static Future<Map<String, bool>> readNotRelevantMarks() async {
    //Aufbau des Returns: Future<Map<Fachname, relevant>>
    //Die Daten aus dem File userNotRelevantMarks auslesen -> Es sind nur Entries der Fächer, welche nicht relevant sind
    Map<String, dynamic> notRelevantsMarks =
        await User.readFile(requiredFile.userNotRelevantMarks);
    if (notRelevantsMarks == {}) {
      return {};
    }

    //Die marks durch interiieren
    //Alle fächer für relevant Eintrag: false einfügen
    Map<String, dynamic> marks = await User.readFile(requiredFile.userMarks);

    for (int i = 0; i < marks.length; i++) {
      String key = marks.keys.toList()[i];
      Map<String, dynamic> value = marks.values.toList()[i];

      value['relevant'] = false;

      marks[key] = value;
    }

    //Falls ein Fach gefunden wird, dann den eintrag durch true ersetzen
    for (int j = 0; j < marks.length; j++) {
      String marksKey = marks.keys.toList()[j];
      Map<String, dynamic> marksValue = marks.values.toList()[j];
      String marksFachname = marksValue['Fach'];

      bool notRelevantsMarksBool = notRelevantsMarks.values.toList()[j];

      if (notRelevantsMarksBool) {
        marksValue['relevant'] = true;
        marks[marksKey] = marksValue;
      }
    }

    //Marks in File:userMarks speichern -> Zweck: Methode kann auch als aktualiseriung verwendet werden für notRelMarks
    User.writeInToFile(marks, requiredFile.userMarks);

    //marks durch iterieren und dessen Fachname als Key und dessen relevant als Value in notRelevantsMarksBool speichern
    Map<String, bool> notRelevantsMarksBool = {};
    for (int i = 0; i < marks.length; i++) {
      Map<String, dynamic> value = marks.values.toList()[i];
      String marksFachname = value['Fach'];
      bool marksRelevant = value['relevant'];

      notRelevantsMarksBool[marksFachname] = marksRelevant;
    }

    return notRelevantsMarksBool;
  }

  static Future<void> refreshNotRelevantMarks(
      Map<String, dynamic> userMarks) async {
    Map<String, dynamic> notRelevantsMarks =
        await User.readFile(requiredFile.userNotRelevantMarks);

    //Die marks durch interiieren
    //Alle fächer für relevant Eintrag: false einfügen
    Map<String, dynamic> marks = userMarks;

    for (int i = 0; i < marks.length; i++) {
      String key = marks.keys.toList()[i];
      Map<String, dynamic> value = marks.values.toList()[i];

      value['relevant'] = false;
      marks[key] = value;
    }

    //Falls ein Fach gefunden wird, dann den eintrag durch true ersetzen
    for (int j = 0; j < marks.length; j++) {
      String marksKey = marks.keys.toList()[j];
      Map<String, dynamic> marksValue = marks.values.toList()[j];
      String marksFachname = marksValue['Fach'];

      bool notRelevantsMarksBool = notRelevantsMarks.values.toList()[j];

      if (notRelevantsMarksBool) {
        marksValue['relevant'] = true;
        marks[marksKey] = marksValue;
      }
    }

    //Marks in File:userMarks speichern -> Zweck: Methode kann auch als aktualiseriung verwendet werden für notRelMarks
    User.writeInToFile(marks, requiredFile.userMarks);
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

    //Nicht relevante Daten anwenden
    //Laden der der Nichtrelevante Noten
    Map<String, bool> userNotRelevantMarks = await User.readNotRelevantMarks();
    //Liste der mit den boolean erstellen
    List<bool> userNotRelevantMarksBool = userNotRelevantMarks.values.toList();
    //Die userMarks durch iterrieren und diese in die Fächer von userMarks einsetzen unter dem Parameter "relevant"
    for (int i = 0; i < userMarks.length; i++) {
      String keyUserMarks = userMarks.keys.toList()[i];
      Map<String, dynamic> value = userMarks.values.toList()[i];
      value['relevant'] = userNotRelevantMarksBool[i].toString();
      userMarks[keyUserMarks] = value;
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
    //NotRelevantMarks aktualisieren
    await User.readNotRelevantMarks();

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
    Map<String, dynamic> userMarks =
        await User.readFile(requiredFile.userMarks);

    //Dashboard Informationen
    Map<String, dynamic> userDashboard =
        await User.readFile(requiredFile.userDashboard);
    userDashboard['saldo'] = await saldo(userMarks);
    await User.writeInToFile(userMarks, requiredFile.userMarks);
  }
}
