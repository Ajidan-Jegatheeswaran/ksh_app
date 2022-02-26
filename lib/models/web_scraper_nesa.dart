// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:ksh_app/models/user.dart';
import 'package:web_scraper/web_scraper.dart';

enum NaviPage {
  home,
  noten,
  absenzen,
  kontoauszug,
  agenda,
  kommunikation,
  listenUndDok,
  eSchool
}

enum HomePageInfo { information, openAbsence, newMarks }

class WebScraperNesa {
  //User Daten
  final String username;
  final String password;
  final String host;
  //Hier wird der Client gestartet, damit der loginhash für den Login übereinstimmt mit dem gebrauchten loginhash
  final client = http.Client();

  // ignore: prefer_final_fields
  var _document = '';
  var loginhash = '';
  Map<String, String> form = {};
  Map<String, String> _header = {};
  Map<String, String> body = {};

  //Das sind die Variabeln des Headers für den body der Post Methode
  Map<String, String> mapHeader = {};
  String phpSecurityHeader = '';
  String longCodeHeader = '';

  //WebScraper Objekt -> Mit diesen kann man HTML in String Form in einen Tree verwandeln und danach die einzelnen Elemente herausfiltern oder die Inhalte dessen Attribute
  WebScraper webscraper = WebScraper();

  //Other Variables
  String _homeHtml = '';

  //Konstruktor
  WebScraperNesa(
      {@required required this.username,
      @required required this.password,
      @required required this.host});

  //Maps
  Map<String, dynamic> homeData = {};
  var listOpenAbsenzHome;
  var listNotConfirmedMarksHome;

  Map<String, dynamic> noten = {};

  Map<String, dynamic> absenzen = {};
  Map<String, dynamic> kontoauszug = {};

  String openAbsence = '';
  Map<String, dynamic> repairedNewMarks = {};
  Map<String, dynamic> repairedOpenAbsences = {};
  bool absenceError = false;

  int countNewStart = 0;

  Future<Map<String, String>> cookies(
      {bool isPathSecond = false,
      bool isNoLongCodeHeader = false,
      bool isCalendar = false}) async {
    String? res = _header['set-cookie'];
    
    
    if (!isPathSecond) {
      phpSecurityHeader = res!.split(';')[0];
    } else if (isPathSecond) {
      longCodeHeader = res!.split(';')[0];
      
    } else if (isNoLongCodeHeader || res!.length < 2) {
      
    } else {
      longCodeHeader = res.split(';')[1].split(',')[1];
    }

    Map<String, String> result = {
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Accept-Language': 'de,de-DE;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
      'Cache-Control': _header['cache-control'] as String,
      'Connection': 'keep-alive',
      'Cookie': 'layout-size=md; menuHidden=0; ' +
          phpSecurityHeader +
          '; path=/,' +
          longCodeHeader +
          '; Path=/; Domain=.nesa-sg.ch',
      'Host': '$host.nesa-sg.ch',
      'User-Agent': 'Dart/2.14 (dart:io)',
      'date': 'Sun, 17 Oct 2021 19:44:14 GMT',
      'strict-transport-security':
          'max-age=31536000; includeSubDomains; preload',
      'pragma': 'no-cache',
      'x-frame-options': 'deny, expires: Mon, 26 Jul 1997 05:00:00 GMT'
    };
    if (isCalendar) {
      Map<String, String> result = {
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept-Language': 'de,de-DE;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
        'Cache-Control': _header['cache-control'] as String,
        'Connection': 'keep-alive',
        'Cookie': 'layout-size=md;' +
            phpSecurityHeader +
            '; path=/,' +
            longCodeHeader +
            '; Path=/; Domain=.nesa-sg.ch',
        'Host': '$host.nesa-sg.ch',
        'User-Agent': 'Dart/2.14 (dart:io)',
        'date': 'Sun, 17 Oct 2021 19:44:14 GMT',
        'strict-transport-security':
            'max-age=31536000; includeSubDomains; preload',
        'pragma': 'no-cache',
        'x-frame-options': 'deny, expires: Mon, 26 Jul 1997 05:00:00 GMT',
        'X-Requested-With': 'XMLHttpRequest'
      };
    }
    
    return result;
  } //'content-length': '90',

  bool isLogin() {
    try {
      webscraper.loadFromString(_document);
      var nav = webscraper.getElement('#nav-main-menu',
          ['style="display: flex; width: 1552px; overflow: hidden;"']);
      String navTitle =
          nav[0].values.toString().split(',')[0].replaceAll('(', '');

      if (navTitle ==
          'StartNotenAbsenzenKontoauszugAgendaKommunikationListen&Dok.eSchool') {
        return true;
      } else {
        throw Exception(
            'Nicht mehr angemeldet...'); //TODO: Exception später entfernen
        return false;
      }
    } on RangeError catch (e) {
      return false;
    }
  }

  //User wird angemolden
  Future<bool> login() async {
    try {
      //Html von Login Page wird geholt
      var res = await client.post(
        Uri.parse('https://$host.nesa-sg.ch/loginto.php?mode=0&lang='),
      );
      //Überprüfung, ob res.body leer ist
      if (res.body.isNotEmpty) {
        _document = res.body;
      } else if (res.body.isEmpty) {
        throw Exception('res.body von Login Page ist leer');
      } else {
        throw Exception();
      }
      _header = res.headers;
    } on Error catch (error) {
      throw error; //TODO: Exception behandeln und beachten, dass dann _document leer ist und der folgende Code diese benutzen will d.h. Ketten Exceptions
    }

    if (_document != Null) {
      webscraper.loadFromString(_document
          .toString()); //From String Html wird es in einen Tree "verwandelt" mit einem Parser() -> Das ist in der Dokumentation des Package Entwicklers ersichtlich
      //Herausfiltern des Input Elements, welches den Loginhash beinhaltet und returnen des Loginhashes

      //Loginhash wird in die Variable loginhash zugeschrieben
      loginhash = webscraper.getElementAttribute(
              '#standardformular > div > div.mdl-cell.mdl-cell--12-col > input',
              'value')[1]
          as String; //Der Webscraper gibt alles zurück, was auf die Beschreibung passt, deshalb wird hier nur das relavante also die 2. Stelle genommen (1, da die Liste bei 0 anfängt)
    }
    await cookies();
    await send();
    if (isLogin()) {
      
      return true;
    } else {
      
      return false;
    }
  }

  //Schickt die Benutzerdaten dem Post-Link, um durch das Login System zu passieren
  Future<void> send() async {
    //form beinhaltet alle Daten, die von nesa-sg.ch für den Login verlangt werden
    form = {"login": username, "passwort": password, "loginhash": loginhash};

    //Mittels Post Request werden die form Daten versendet
    Map<String, String> cookies_data = await cookies();

    Response res = await client.post(
      Uri.parse('https://$host.nesa-sg.ch/index.php?pageid=1'),
      headers: cookies_data,
      body: form,
    );

    //Überprüft, ob die Anfrage und Empfang erfolgreich war
    if (res == Null) {
      throw Exception('Response wurde nicht gesetzt');
    }

    if (res.statusCode == 200) {
      _document = res.body;
      _homeHtml = res.body;
      
      _header = res.headers;
      if (isLogin()) {
        
      } else {
        //TODO:
      }

      webscraper.loadFromString(_document);
    } else {
      if (res.isRedirect) {
       
      }

      throw Exception('Nutzeranfrage war nicht erfolgreich');
    }
  }

  String buildLink(String frag) {
    return 'https://$host.nesa-sg.ch/' + frag;
  }

  //Führt eine Post Methode durch, um auf die nächste Seite zu kommen und liefert die HTML Code zurück
  Future<String> _getPageContent(String followingPage) async {
    Uri uri = Uri.parse(followingPage);
    List<String> data = uri.query.split('&');
    body = {};

    for (String i in data) {
      List<String> list = i.split('=');
      body[list[0]] = list[1];
    }

    var res = await client.post(uri, body: body, headers: await cookies());
    _header = res.headers;
    

    var content = res.body;
   
    return content;
  }

  //Methode, um den Webscraper die benötigte Seite von den 8 Navigationsseiten zu übergeben -> Code sparen + Effizienteres Arbeiten
  Future<void> setNavigationPageContent(Enum c) async {
    if (!isLogin()) {
      throw ('Nicht angemeldet');
    }
    bool _isLoad = webscraper.loadFromString(_document);
   

    //Hier wird die ID (HTML) vom jeweiligen Element geschickt, welches den Link zu einer der Navigationsseiten von Nesa hat
    Future<String> getNavigationPage() async {
      String menu;
      String _content = '';

      switch (c) {
        case NaviPage.home:
          menu = '#menu1';
          break;
        case NaviPage.noten:
          menu = '#menu21311';
          break;
        case NaviPage.absenzen:
          menu = '#menu21111';
          break;
        case NaviPage.kontoauszug:
          menu = '#menu21411';
          break;
        case NaviPage.agenda:
          menu = '#menu21200';
          break;
        case NaviPage.kommunikation:
          menu = '#menu22300';
          break;
        case NaviPage.listenUndDok:
          menu = '#menu24030';
          break;
        case NaviPage.eSchool:
          menu = '#menu23118';
          break;

        default:
          throw Exception(''); //TODO: Exception
      }

      var link = webscraper.getElementAttribute(menu, 'href');
     

      if (link.length > 1 || link.isEmpty) {
        throw Exception('Etwas ist schief gelaufen'); //TODO: Exception
      }

      await _getPageContent(buildLink(link[0].toString())).then((val) {
        _content = val;
     
      });

      return _content;
    }

    String cont = '';
    await getNavigationPage().then((value) {
      cont = value;
    });
    _isLoad = webscraper.loadFromString(cont);
    if (!_isLoad) {
      throw Exception(); //TODO: Exception
    }
  }
/*
  String formatSelector(String selector) {
    //TODO: Methode funktioniert noch nicht
    List<String> list = selector.split(' > ');

    for (String i in list) {
      i.toString().replaceAll(' ', '.');
    }
    String string = '';
    for (int i = 0; i < list.length; i++) {
      if (i == (list.length - 1)) {
        string += list[i];
      } else {
        string += list[i] + ' > ';
      }
    }

    return string.trim();
  } */

  //Holt die Daten von der Startseite von Nesa

  Future<Map<String, dynamic>> getHomeData(Enum homepageInformation,
      {int numAbsence = 0}) async {
    //NEUER ALGO
    //Laden der TD Elemente
    webscraper.loadFromString(_homeHtml);
    List<Map<String, dynamic>> tds = webscraper.getElement('td', []);
    List values = [];
    //Inhalt der tds werden extrahiert
    for (Map<String, dynamic> item in tds) {
      values.add(item['title']);
    }

    //Hier sind die Speicherorte der Informationen
    Map<String, dynamic> _userInformation = {};
    List<String> _userInfomationList = [];
    Map<String, dynamic> _openAbsences = {};
    List<String> _userAbsencesList = [];
    Map<String, dynamic> _newMarks = {};
    List<String> _userNewMarksList = [];

    //Alle Inhalte der TD Elemente durch iterieren und Zuteilung in Personeninforamtion, Offene Absenz und Neue Note machen

    bool newMarkBool = false;

    for (int k = 0; k < values.length; k++) {
      String str = values[k];

      if (k < 16) {
        _userInfomationList.add(str);
      } else if (k > 15) {
        if (str.contains('''
                Sie haben keine offenen Absenzen.
            ''')) {
          continue;
        }

        //Überprüfen, ob es eine Absenz ist, sonst zu New Marks weiterleiten (newMarkBool = true)
        if (str.contains('von:') ||
            str.contains('bis: ') ||
            str.contains('Entschuldigen bis:')) {
          _userAbsencesList.add(str);
        } else {
          _userNewMarksList.add(str);
        }
      }
    }
    String key = '';

    //User Informationen in eine Map verpacken
    for (int j = 0; j < _userInfomationList.length; j++) {
      String str = _userInfomationList[j];

      if (j.isEven) {
        //Ungerade
        key = str;
      } else {
        _userInformation[key] = str;
      }
    }
    //Absenzen in eine Map verpacken
    int _counter = 0;
    int _keyCounter = 0;
    Map<String, dynamic> absence = {};

    for (var i = 0; i < _userAbsencesList.length; i++) {
      String str = _userAbsencesList[i];
      switch (_counter) {
        case 0:
          if (str.contains('von:')) {
            String res = str.replaceAll('von: ', '');
            absence['from'] = res;
          }
          _counter++;
          break;
        case 1:
          if (str.contains('bis:')) {
            String res = str.replaceAll('bis: ', '');
            absence['to'] = res;
          }
          _counter++;
          break;
        case 2:
          if (str.contains('Entschuldigen bis:')) {
            String res = str.replaceAll('Entschuldigen bis: ', '');
            absence['deadline'] = res;
            _openAbsences[_keyCounter.toString()] = absence;
            _keyCounter++;
          }
          _counter = 0;
          break;
      }
    }

    _counter = 0;
    Map<String, dynamic> _newMark = {};
    _keyCounter = 0;
    //Neue Noten in eine Map verpacken
    for (var i = 0; i < _userNewMarksList.length; i++) {
      String str = _userNewMarksList[i];

      switch (_counter) {
        case 0:
          _newMark['title'] = str;
          _counter++;
          break;

        case 1:
          _newMark['testName'] = str;
          _counter++;
          break;

        case 2:
          _newMark['date'] = str;
          _counter++;
          break;

        case 3:
          _newMark['valuation'] = str;
          _newMarks[_keyCounter.toString()] = _newMark;
          _newMark = {};
          _counter = 0;
          _keyCounter++;
          break;
      }
    }

    //Resulate wiedergeben

    switch (homepageInformation) {
      case HomePageInfo.information:
        return _userInformation;

      case HomePageInfo.newMarks:
        return _newMarks;

      case HomePageInfo.openAbsence:
        return _openAbsences;

      default:
        return {};
    }

    //ALTER ALGO
    /*
    bool checksStatus = false;

    if (!webscraper.loadFromString(_homeHtml)) {
      throw Exception(); //todo: Exception
    }
    webscraper.loadFromString(_homeHtml);
    print(_homeHtml.length);

    //getElement liefert nun alle "td" Elemente
    var listUserData = webscraper.getElement('td', []);

    print('ListUserData');
    print(listUserData);

    String wert1 = '';
    bool isMark = false;
    int loopCounter = 1;
    String listUserDataKey = '';
    String listUserDataValue = '';
    Map<String, dynamic> userInformation = {};

    for (Map<String, dynamic> item in listUserData) {
      String value = item.values.first;
      print('Value');
      print(value);
      Map<String, String> noten = {};

      if (loopCounter < 16) {
        if (loopCounter.isOdd) {
          listUserDataKey = '';
          listUserDataValue = '';
          listUserDataKey = value;
        } else if (loopCounter.isEven) {
          listUserDataValue = value;
          if (listUserDataKey != '' || listUserDataValue != '') {
            userInformation[listUserDataKey] = listUserDataValue;
          }
        }
      }
      //todo: getHomeAlgo

      if (wert1 == '') {
        wert1 = value;
      } else {
        homeData[wert1] = value;
        wert1 = '';
      }
      loopCounter += 1;
    }
    print('Td Länge');
    print(listUserData.length);
    print(listUserData);
    print('Open Absence Print');
    Map<String, dynamic> _map = await User.readFile(requiredFile.userDashboard);
    int numOpenAbsence = numAbsence;
    if (numOpenAbsence == 0) {
      numOpenAbsence = int.parse(_map['openAbsence']);
    } else {
      numOpenAbsence = countNewStart;
    }
    print('NumOpenAbsence');
    print(numOpenAbsence);
    int _counterNewMarks = 0;
    int _counterNewMarks2 = 0;
    int _counterNewMarks3 = 0;
    Map<String, dynamic> newMark = {};
    Map<String, dynamic> allNewMarks = {};

    //Variablen für Absenzen
    Map<String, dynamic> openAbsence = {};
    Map<String, dynamic> openAbsences = {};
    int _counterOpenAbsence = 0;
    int _counterOpenAbsence2 = 0;

    for (var i in listUserData) {
      if (_counterNewMarks <= (15)) {
        print(_counterNewMarks);
        print('Schleife wurde übersprungen');
        print(i);
        _counterNewMarks++;
        continue;
      }
      String item = i['title'].toString();

      if (_counterNewMarks > 15 &&
          _counterNewMarks < ((3 * numOpenAbsence) + 16)) {
        print(_counterNewMarks);
        print('Offene ABsenzen');
        print(item);

        if (item.contains('Sie haben keine offenen Absenzen.')) {
          break;
        }

        switch (_counterOpenAbsence) {
          case 0:
            openAbsence['from'] = item;
            print('from');
            print(item);
            _counterOpenAbsence++;
            break;
          case 1:
            openAbsence['to'] = item;
            print('to');
            print(item);
            _counterOpenAbsence++;
            break;
          case 2:
            openAbsence['deadline'] = item;
            print('to');
            print(item);
            openAbsences[_counterOpenAbsence2.toString()] = openAbsence;
            print('OpenAbsences');
            print(openAbsences);
            openAbsence = {};
            _counterOpenAbsence = 0;
            _counterOpenAbsence2++;

            break;
        }

        _counterNewMarks++;

        continue;
      }
      print('OpenAbsences');
      print(openAbsences);

      print(_counterNewMarks);
      print('item NewMark');
      print(item);
      switch (_counterNewMarks2) {
        case 0:
          newMark['title'] = item;
          _counterNewMarks2++;
          break;

        case 1:
          newMark['testName'] = item;
          _counterNewMarks2++;
          break;

        case 2:
          newMark['date'] = item;
          _counterNewMarks2++;
          break;

        case 3:
          newMark['valuation'] = item;

          allNewMarks[_counterNewMarks3.toString()] = newMark;
          newMark = {};
          _counterNewMarks++;
          _counterNewMarks2 = 0;
          _counterNewMarks3++;
          break;
      }

      _counterNewMarks++;
    }

    //Überprüfung des Resultats von allNewMarks
    if (allNewMarks.length == 0) {
      allNewMarks = {};
    } else {
      //Alle Titel von AllNewMarks extrahieren
      List<String> newMarkTitles = [];

      for (Map<String, dynamic> item in allNewMarks.values) {
        String itemString = item['title'];
        newMarkTitles.add(itemString);
      }
      print('NewMarkTitles');
      print(newMarkTitles);

      //Laden der Titel der Fächer aus getMarksData
      Map<String, dynamic> marks = await getMarksData();
      print('Marks NewMarks Check');
      print(marks);
      List<String> allTitle = marks.keys.toList();

      //Jeder Titel von newMarkTitles wird mit allTitle verglichen, um zu überprüfen, ob dass überhaupt ein Titel von einem Fach ist.

      for (var i = 0; i < newMarkTitles.length; i++) {
        for (String item in allTitle) {
          if (item
              .toString()
              .split(' ')[0]
              .contains(newMarkTitles[i].toString())) {
            checksStatus = true;
            numOpenAbsence = countNewStart;
            repairedNewMarks = allNewMarks;
            repairedOpenAbsences = openAbsences;
          }
        }
        if (checksStatus == false) {
          countNewStart++;
          allNewMarks = await getHomeData(HomePageInfo.newMarks,
              numAbsence: countNewStart);
          print('AllNewMarks after repair');
          print(allNewMarks);
          if (countNewStart > 19) {
            throw Exception(
                'Neue Noten konnten nicht in einer korrekten Form geliefert werden');
          }
        }
      }
    }

    switch (homepageInformation) {
      case HomePageInfo.information:
        print('UserInformation');
        print(userInformation);
        return userInformation;

      case HomePageInfo.newMarks:
        if (repairedNewMarks == {}) {
          return allNewMarks;
        } else {
          return repairedNewMarks;
        }

      case HomePageInfo.openAbsence:
        if (repairedOpenAbsences == {}) {
          return openAbsences;
        } else {
          return repairedOpenAbsences;
        }

      default:
        return {};
    }*/
  }

  //Alle Notenschnitte der Fächer und weiteres ohne die Einzelnoten werden geladen
  Future<Map<String, dynamic>> getMarksData() async {
    //Web Scraper auf NaviPage.Noten gestellt
    await setNavigationPageContent(NaviPage.noten);

    //Anzahl Fächer
    List listSubjectTitle =
        webscraper.getElement('table > tbody > tr > td > b', []);
    int numberOfMarks = listSubjectTitle.length;
    int counterListSubjectTitle = 0;

    var listMarks = webscraper.getElement(
        'table.mdl-data-table.mdl-js-data-table.mdl-table--listtable > tbody > tr:not([class]) > td', //#uebersicht_bloecke > page > div > table > tbody > tr:nth-child(5) > td:nth-child(1)
        []);

    int counter = 1;
    int counter2 = 0;
    String subjectName = "";
    String subjectMark = "";
    String isConfirmed = '';
    //In der For-Schleife werden alle Listen Elemente durch gegangen und dabei ein jedes Szenarie (case) der Counter um eins erhöhrt
    for (var item in listMarks) {
      String res = item.values.first;
      res = res.trim();

      switch (counter) {
        case 1:
          subjectName =
              res.replaceAll(listSubjectTitle[counter2].values.first, '');
          counter += 1;
          break;
        case 2:
          subjectMark = res.replaceAll(' ', '');
          if (subjectMark == '--') {
            subjectMark = '--';
          }
          counter += 1;
          break;
        case 3:
          counter += 1;
          break;
        case 4:
          
          if (res != '--') {
            if (res.contains('ja')) {
              isConfirmed = 'ja';
            } else if (res.contains('bestätigen')) {
              isConfirmed = 'nein';
            } else {
              throw Exception('IsConfirmed If Else FUnktioniert nicht');
            }
           
          } else {
            isConfirmed = '--';
          }
         

          //Note in Map impotieren
          if (subjectMark != '' && subjectName != '' && isConfirmed != '') {
            Map<String, String> dataMarks = {};
            dataMarks['Fach'] = subjectName;
            dataMarks['Note'] = subjectMark;
            dataMarks['Noten bestätigt'] = isConfirmed;
            noten[listSubjectTitle[counter2].values.first] = dataMarks;
           
          } else {
            throw Exception(); //TODO: Exception
          }

          counter += 1;
          break;

        case 6:
         
          counter = 1;
          counter2 += 1;
          break;
        default:
         
          counter += 1;
          break;
      }
    }

    
    return noten;
  }

  Future<Map<String, dynamic>> getAllMarks() async {
    //Facher werden aus getMarksData geladen und die Fächer Namen werden in eine Liste importiert
    Map<String, dynamic> marks = await getMarksData();

    List<String> markNames = [];

    //Laden Aller Fächer mit dem dazugehörigen Notenschnitt im Fach
    for (var e in marks.entries.toList()) {
      Map<String, dynamic> value = Map<String, dynamic>.from(e.value);
      var _mark = value['Note'];
      if (_mark.replaceAll(' ', '') == '--') {
        continue;
      }
      markNames.add(value['Fach']);
    }

    //Alle Element von HTML Code extrahieren
    //td Elemente, welche unteranderm die Einzelnoten der Fächer enthalten werden herausgefiltert
    List listMarks = webscraper.getElement('tr>td>table>tbody>tr>td', []);
    

    //Die gebrauchten Daten werden herausgenommen und die Liste titleListMarks gespeichert
    List titleListMarks = [];
    for (var item in listMarks) {
      String markString = item
          .toString()
          .replaceAll('{', '')
          .replaceAll('}', '')
          .split(',')[0]
          .split(': ')[1];
      titleListMarks.add(markString);
    }
  

    //Alle Listen Elemente, welche 'Datum', 'Thema', 'Bewertung', und 'Gewichtung' enthalten werden entfert.
    //Und an dieser Stelle wird der Fach Name eingefügt
    int counterSubjectsTitleListMarks = 0;
    for (int index = 0; index < titleListMarks.length; index++) {
      String cache = titleListMarks[index];

      titleListMarks.remove('');
      titleListMarks.remove('Bewertung');
      titleListMarks.remove('Datum');
      titleListMarks.remove('Thema');
    }
  
    counterSubjectsTitleListMarks = 0;
    for (int j = 0; j < titleListMarks.length; j++) {
      var i = titleListMarks[j];
      if (i.contains('Gewichtung')) {
        
        titleListMarks[j] = markNames[counterSubjectsTitleListMarks];
        counterSubjectsTitleListMarks++;
      }
    }

    

    //Es wird eine Map erstellt bei dem der Key Wert der Name des Faches ist und der Value Wert eine List von Noten mit den jeweiligen Zusatzinformation wie Datum, Thema,...
    counterSubjectsTitleListMarks = 0;

    bool isSubjectStart = false;
    String currentSubject = '';
    String nextSubject = '';
    counterSubjectsTitleListMarks = 0;
    int switchCounter = 0;

    Map<String, dynamic> _subjects = {};
    Map<String, dynamic> _subject = {};
    List _listSubjects = [];

    bool aktuellerDurchschnitt = false;

    //Entfernen aller "Aktueller Durchschnitt" und dazugehöriger Notenschnitt
    bool aktuellerDurchschnittGefunden = false;
    List<String> clearedList = [];

    for (String s in titleListMarks) {
      if (aktuellerDurchschnittGefunden) {
        aktuellerDurchschnittGefunden = false;
        continue;
      }
      if (!s.contains('Aktueller Durchschnitt:')) {
        clearedList.add(s);
      } else {
        aktuellerDurchschnittGefunden = true;
      }
    }

    //Algorithmus: Einteilung der Einzelnen Noten zu den Fächern
    //clearedList -> Enthält Inhalt der TD Elemente
    //markNames -> Enthält die Namen der Fächer

    bool continueLoop = false;
    Map<String, List<Map<String, dynamic>>> allSubs = {};
    int counter = 0;
    String currentSub = '';
    List<Map<String, dynamic>> listOfSingleMarks = [];

    for (String t in clearedList) {
      //Überprüfen, ob es sich bei t um ein Fach handelt
      for (String sub in markNames) {
        if (t == sub) {
          if (currentSub != '') {
            allSubs[currentSub] = listOfSingleMarks;
          }

          currentSub = sub;
          listOfSingleMarks = [];
          continueLoop = true;
          break;
        }
      }
      if (continueLoop) {
        continueLoop = false;
        continue;
      }
      switch (counter) {
        case 0:
          _subject['date'] = t;
          counter++;
          break;
        case 1:
          _subject['topic'] = t;
          counter++;
          break;
        case 2:
          _subject['valuation'] = t
              .replaceAll(' ', '')
              .replaceAll('DetailszurNotePunkte', '')
              .replaceAll(' ', '');
          counter++;
          break;
        case 3:
          _subject['weighting'] = t;
          counter = 0;
          listOfSingleMarks.add(_subject);
         
          _subject = {};
          break;
      }
    }

    /*
    //Prüfung
    for (int k = 0; k < titleListMarks.length; k++) {
      if (counterSubjectsTitleListMarks == markNames.length) {
        break;
      }
      if (aktuellerDurchschnitt) {
        aktuellerDurchschnitt = false;
        continue;
      }
      String item = titleListMarks[k];
      if (item.contains('Aktueller Durchschnitt:')) {
        aktuellerDurchschnitt = true;
        continue;
      }

      if (item.contains(markNames[counterSubjectsTitleListMarks])) {
        _subjects[currentSubject.toString()] = _listSubjects;
        print('currentSubject');
        print(currentSubject);
        _subject = {};

        print('Subjects');
        print(_subjects);

        currentSubject = markNames[counterSubjectsTitleListMarks];
        if ((counterSubjectsTitleListMarks + 1) != markNames.length) {
          print('Lenght');
          print(counterSubjectsTitleListMarks);
          print(titleListMarks.length);
          nextSubject = markNames[counterSubjectsTitleListMarks + 1];
        } else {
          nextSubject = '';
        }
        counterSubjectsTitleListMarks++;
        _listSubjects = [];
        isSubjectStart = true;
      } else if (isSubjectStart) {
        switch (switchCounter) {
          case 0:
            _subject['date'] = item;
            switchCounter++;
            break;
          case 1:
            _subject['topic'] = item;
            switchCounter++;
            break;
          case 2:
            _subject['valuation'] = item
                .replaceAll(' ', '')
                .replaceAll('DetailszurNotePunkte', '')
                .replaceAll(' ', '');
            switchCounter++;
            break;
          case 3:
            _subject['weighting'] = item;
            switchCounter = 0;
            _listSubjects.add(_subject);
            print('Subject Map');
            print(_subject);
            _subject = {};
            break;
        }
      }
    }
    */
    allSubs[currentSub] = listOfSingleMarks;
  

    return allSubs;
  }

  //Funktioniert nicht so wie geplant, aber die offenen Absenzen werden über die Startseite geholt und diese Funktion liefert nur die Anzahl der offenen Absenzen die in openAbsence zugewiesen
  Future<Map<String, dynamic>> getAbsenceData() async {
    await setNavigationPageContent(NaviPage.absenzen);

    List listOfAbsence = webscraper.getElement('td', []);
    int anzahlAbsenzen = int.parse(listOfAbsence
        .where((element) {
          String test = element.toString();

          return test.contains('Anzahl Ereignisse');
        })
        .toList()[0]
        .values
        .first
        .split(': ')[1]);

    Map<String, String> absenz = {};
    List<Map<String, String>> absenzenList = [];
    int indexCounter = 0;
    int indexAbsence = 1;

    for (Map i in listOfAbsence) {
      String item = i.values.first.replaceAll(' ', '');
      int tdLenghtOfAbsenzauszug = ((anzahlAbsenzen * 7) + 1);
      if (indexCounter <= tdLenghtOfAbsenzauszug) {
        switch (indexCounter) {
          case 0:
            absenz['dateFrom'] = item;
            indexCounter += 1;
            break;
          case 1:
            absenz['dateTo'] = item;
            indexCounter += 1;
            break;
          case 2:
            absenz['reason'] = item;
            indexCounter += 1;
            break;
          case 3:
            absenz['moreInfos'] = item;
            indexCounter += 1;
            break;
          case 4:
            absenz['additionalPeriod'] = item;
            indexCounter += 1;
            break;
          case 5:
            absenz['excuse'] = item;
            indexCounter += 1;
            break;
          case 6:
       
            absenz['lections'] =
                item.split('ZudieserAbsenzerfasstenMeldungen')[0];

            List<int> anzahlEreignisseAll = [];
            List elementAnzahlEreignisseAll = listOfAbsence.where((element) {
              String test = element.toString();

              return test.contains('Anzahl Ereignisse');
            }).toList();
           
            openAbsence = elementAnzahlEreignisseAll[1]['title']
                .split(': ')[1]
                .replaceAll(' ', '');
            for (int indexAnzahlEreignisseAll = 0;
                indexAnzahlEreignisseAll < 3;
                indexAnzahlEreignisseAll++) {
              String itemAnzahlEreignisse = '';
              if (indexAnzahlEreignisseAll ==
                  elementAnzahlEreignisseAll.length) {
                break;
              }

              itemAnzahlEreignisse =
                  elementAnzahlEreignisseAll[indexAnzahlEreignisseAll]
                      .values
                      .first
                      .replaceAll(' ', '')
                      .split(':')[1];

             

              anzahlEreignisseAll.add(int.parse(itemAnzahlEreignisse));
            }

            absenzenList.add(absenz);
            absenz = {};

            if ((anzahlEreignisseAll[0]) == indexAbsence) {
              absenzen['absenzenauszug'] = absenzenList;
              absenzenList = [];
            }
            indexAbsence += 1;
            indexCounter = 0;
            break;
          default:
            throw Exception(); //todo: Exception
        }
      }
    }
 
    return absenzen;
  }

  //Funktioniert nicht... wurde nur angefangen
  Future<String> getUserImageNetworkPath() async {
    await setNavigationPageContent(NaviPage.listenUndDok);
    String _resLink = webscraper
        .getElementAttribute('#cls_pageid_nav_24184', 'href')[0]
        .toString();
  
    Response _response = await client.post(Uri.parse(buildLink(_resLink)),
        body: body, headers: await cookies(isNoLongCodeHeader: true));

   

    webscraper.loadFromString(_response.body);
    String _resData =
        webscraper.getElementAttribute('img', 'src')[1].toString();

    String completeLink = buildLink(_resLink);
  
    return completeLink;
  }

  //Schliesst den Client
  void closeClient() => client.close();

  //Kalenderdaten Webserver verweigert die Anfrage d.h. Anfrage muss umgeändert werden
  getCalendarData() async {
    DateTime dateNow = DateTime.now();
    String currentDate = dateNow.year.toString() +
        '-' +
        dateNow.month.toString() +
        '-' +
        dateNow.day.toString();
 

    await setNavigationPageContent(NaviPage.agenda);
    String link = webscraper
        .getElementAttribute('#cls_pageid_nav_21312', 'href')[0]
        .toString();
   

    Uri uriQuery = Uri.parse(buildLink(link));
    List<String> data = uriQuery.query.split('&');
    
    data.add('ansicht=klassenuebersicht');
    data.add('view=month');
    data.add('curr_date=' + currentDate);
    data.add('showOnlyThisClass=-2');
    if (dateNow.month >= 8 && dateNow.month <= 2) {
      data.add('min_date=2021-09-15');
      data.add('max_date=2022-01-31');
    } else {
      data.add('min_date=2022-01-31');
      data.add('max_date=2021-09-15');
    }
    data.add('timeshift=-60');

    
    Map<String, String> body = {};

    for (int j = 0; j < 3; j++) {
      String i = data[j];
      List<String> list = i.split('=');
      body[list[0]] = list[1];
    }
 

    String url = 'https://$host.nesa-sg.ch/scheduler_processor.php?';
    for (String item in data) {
      url += item;
      if (item != 'timeshift=-60') {
        url += '&';
      }
    }
    String i1 = '';
    String i2 = '';
    for (String i in data) {
      if (i1 == '') {
        i1 = i;
      } else {
        i2 = i;
        body[i1] = i2;
        i1 = '';
        i2 = '';
      }
    }
    
    Uri uri = Uri.parse(url);
    var res = await client.post(uri,
        body: body,
        headers: await cookies(isPathSecond: true, isCalendar: true));
   
    _header = res.headers;

    var content = res.body;
    

    webscraper.loadFromString(res.body);

    
  }
}
