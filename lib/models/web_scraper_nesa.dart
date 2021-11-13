// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
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
  late String _homeHtml;

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

  Future<Map<String, String>> cookies(
      {bool isPathSecond = false, bool isNoLongCodeHeader = false}) async {
    String? res = _header['set-cookie'];
    print('Result');
    print(res);
    print(res!.split(';')[1].split(','));
    if (!isPathSecond) {
      phpSecurityHeader = res.split(';')[0];
    } else if (isPathSecond) {
      longCodeHeader = res.split(';')[0];
      print(longCodeHeader);
    } else if (isNoLongCodeHeader || res.length < 2) {
      print('Hier gibt es keinen NoLongCodeHeader');
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
    print(result);
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
      print('Anmeldung Erfolgreich');
      return true;
    } else {
      print('Anmeldung fehlgeschlagen');
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
      print('Home HTML Lenght');
      print(_homeHtml.length);
      print(res.contentLength);
      _header = res.headers;
      if (isLogin()) {
        print('Erfolgreich angemeldet...');
      } else {
        //TODO:
      }

      webscraper.loadFromString(_document);
    } else {
      if (res.isRedirect) {
        print('isRedirect');
        print(res.isRedirect);
      }
      throw Exception(
          'Status Code ist nicht 200, sondern ' + res.statusCode.toString());
    }
  }

  String buildLink(String frag) {
    return 'https://$host.nesa-sg.ch/' + frag;
  }

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
    print('header');
    print(_header);

    var content = res.body;
    print(res.contentLength);
    return content;
  }

  //Methode, um den Webscraper die benötigte Seite von den 8 Navigationsseiten zu übergeben -> Code sparen + Effizienteres Arbeiten
  Future<void> setNavigationPageContent(Enum c) async {
    if (!isLogin()) {
      throw ('Nicht angemeldet');
    }
    bool _isLoad = webscraper.loadFromString(_document);
    print('Dokument');
    print(_document);

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
      print('Link');
      print(link);

      if (link.length > 1 || link.isEmpty) {
        throw Exception('Etwas ist schief gelaufen'); //TODO: Exception
      }

      await _getPageContent(buildLink(link[0].toString())).then((val) {
        _content = val;
        print('PageContent');
        print(_content);
        print('PageLenght');
        print(_content.length);
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

  Future<Map<String, dynamic>> getHomeData(Enum homepageInformation) async {
    if (_homeHtml == Null) {
      throw Exception(); //todo: Excpetion
    }

    if (!webscraper.loadFromString(_homeHtml)) {
      throw Exception(); //todo: Exception
    }
    webscraper.loadFromString(_homeHtml);
    print(_homeHtml.length);

    //Get all User Data
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
    switch (homepageInformation) {
      case HomePageInfo.information:
        print('UserInformation');
        print(userInformation);
        return userInformation;
      default:
        return {};
    }
  }

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
    for (var item in listMarks) {
      String res = item.values.first;
      res = res.trim();
      print(res);

      switch (counter) {
        case 1:
          subjectName =
              res.replaceAll(listSubjectTitle[counter2].values.first, '');
          counter += 1;
          print('Subject Name');
          print(subjectName);
          break;
        case 2:
          subjectMark = res.replaceAll(' ', '');
          if (subjectMark == '--') {
            subjectMark = '--';
          }
          counter += 1;
          print('SubjectMark');
          print(subjectMark);
          break;
        case 3:
          print('Case 3');
          print(res);
          counter += 1;
          break;
        case 4:
          print('Case 4');
          print(res);
          if (res != '--') {
            if (res.contains('ja')) {
              isConfirmed = 'ja';
            } else if (res.contains('bestätigen')) {
              isConfirmed = 'nein';
            } else {
              throw Exception('IsConfirmed If Else FUnktioniert nicht');
            }
            print('IsConfirmed');
            print(isConfirmed);
          } else {
            isConfirmed = '--';
          }
          print('Subject Mark');
          print(subjectMark);
          print('Subject Name');
          print(subjectName);

          //Note in Map impotieren
          if (subjectMark != '' && subjectName != '' && isConfirmed != '') {
            Map<String, String> dataMarks = {};
            dataMarks['Fach'] = subjectName;
            dataMarks['Note'] = subjectMark;
            dataMarks['Noten bestätigt'] = isConfirmed;
            noten[listSubjectTitle[counter2].values.first] = dataMarks;
            print('Noten Map');
            print(noten);
          } else {
            throw Exception(); //TODO: Exception
          }

          counter += 1;
          break;

        case 6:
          print('Case 5');
          print(res);
          counter = 1;
          counter2 += 1;
          break;
        default:
          print('Default');
          print(res);
          counter += 1;
          break;
      }
    }

    listMarks = webscraper.getElement('tr>td>table>tbody>tr>td', []);
    print('ListOfMarks');
    print(listMarks);

    Map<String, dynamic> marksOfSubjects = {};
    List<Map<String, dynamic>> listMarksOfSubjects = [];
    int listMarksCounter = 0;
    int listMarksCounterMap = 0;
    int status = 0;
    String date = '';
    String topic = '';
    String valuation = '';
    String weighting = '';
    bool durchschnitt = false;
    for (var i in listMarks) {
      if(durchschnitt){
        durchschnitt = false;
        continue;
      }
      String item = i.values.first.toString().replaceAll(' ', '');
      print('Item');
      print(item);
      if (item.contains('Datum')) {
        status = 0;
        listMarksCounter = 0;
        continue;
      } else if (item.contains('Thema') || item.contains('Bewertung')) {
        print('Neues Thema');
        listMarksCounter = 0;
        continue;
      } else if (item.contains('Gewichtung')) {
        status = 1;
        listMarksCounter = 0;
        continue;
      }

      if (status == 1) {
        switch (listMarksCounter) {
          case 0:
            date = item;
            listMarksCounter++;
            break;
          case 1:
            topic = item;
            listMarksCounter++;
            break;
          case 2:
            valuation = item;
            print(item);
            listMarksCounter++;
            break;
          case 3:
            weighting = item;
            listMarksOfSubjects.add({
              'date': date,
              'topic': topic,
              'valuation': valuation,
              'weighting': weighting
            });
            listMarksCounter++;
            break;
          case 4:
            
            if (item.contains('AktuellerDurchschnitt:')) {
              listMarksCounter = 0;
              date = '';
              topic = '';
              valuation = '';
              weighting = '';
              durchschnitt = true;
            } else {
              date = item;
              listMarksCounter = 1;
            }

            break;
          case 5:
            print('Case 6 storing...');
            marksOfSubjects[noten.keys
                .toList()[listMarksCounterMap]
                .toString()] = listMarksOfSubjects;
            listMarksOfSubjects = [];
            listMarksCounter = 0;
            listMarksCounterMap++;
            break;
        }
      }
    }

    print('MarksOfSubjects');
    print(marksOfSubjects);

    print('Noten Map zum Schluss');
    print(noten);
    return noten;
  }

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
            print('Item');
            print(item);
            absenz['lections'] =
                item.split('ZudieserAbsenzerfasstenMeldungen')[0];

            List<int> anzahlEreignisseAll = [];
            List elementAnzahlEreignisseAll = listOfAbsence.where((element) {
              String test = element.toString();

              return test.contains('Anzahl Ereignisse');
            }).toList();
            print('ElementEreignisse');
            print(elementAnzahlEreignisseAll);
            for (int indexAnzahlEreignisseAll = 0;
                indexAnzahlEreignisseAll < 3;
                indexAnzahlEreignisseAll++) {
              String itemAnzahlEreignisse =
                  elementAnzahlEreignisseAll[indexAnzahlEreignisseAll]
                      .values
                      .first
                      .replaceAll(' ', '')
                      .split(':')[1];
              print('itemAnzahlEreignisse');
              print(itemAnzahlEreignisse);

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

/*
  Future<String> getUserImageNetworkPath() async {
    await setNavigationPageContent(NaviPage.listenUndDok);
    String _resLink = webscraper
        .getElementAttribute('#cls_pageid_nav_24184', 'href')[0]
        .toString();
    print('Schülerübersicht');
    print(_resLink);
    Response _response = await client.post(Uri.parse(buildLink(_resLink)),
        body: body, headers: await cookies(isNoLongCodeHeader: true));

    print('Schülerübersicht Content-Lenght');
    print(_response.contentLength);

    webscraper.loadFromString(_response.body);
    String _resData =
        webscraper.getElementAttribute('img', 'src')[1].toString();
    print(_resData);
    String completeLink = buildLink(_resLink);
    print(completeLink);
    return completeLink;
  }
*/
  /*
  Future<void> getCalendarData() async {
    DateTime dateNow = DateTime.now();
    String currentDate = dateNow.year.toString() +
        '-' +
        dateNow.month.toString() +
        '-' +
        dateNow.day.toString();
    print(currentDate);

    await setNavigationPageContent(NaviPage.agenda);
    String link = webscraper
        .getElementAttribute('#cls_pageid_nav_21312', 'href')[0]
        .toString();
    print(link);

    Uri uri = Uri.parse('https://$host.nesa-sg.ch/scheduler_processor.php?');
    Uri uriQuery = Uri.parse(buildLink(link));
    List<String> data = uriQuery.query.split('&');
    print('Date2');
    print(data);
    data.add('ansicht=klassenuebersicht');
    data.add('view=grid');
    print('Data');
    print(data);
    Map<String, String> body = {};

    for (String i in data) {
      List<String> list = i.split('=');
      body[list[0]] = list[1];
    }

    var res = await client.post(uri,
        body: body, headers: await cookies(isPathSecond: true));
    print(res.contentLength);
    _header = res.headers;

    var content = res.body;
    print(res.contentLength);

    webscraper.loadFromString(res.body);

    print(res.body);


/*
    Uri uri = Uri.parse(buildLink(link));
    List<String> data = uri.query.split('&');
    Map<String, String> body = {};

    for (String i in data) {
      List<String> list = i.split('=');
      body[list[0]] = list[1];
    }
    print('data');
    print(body);
    Response response = await client.post(uri, body: body, headers: await cookies());
    print(response.body);
    */
  }*/

  //Schliesst den Client
  void closeClient() => client.close();
}
