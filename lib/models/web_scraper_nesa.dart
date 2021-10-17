// ignore_for_file: unrelated_type_equality_checks

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:web_scraper/web_scraper.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

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

class WebScraperNesa {
  //Hier wird der Client gestartet, damit der loginhash für den Login übereinstimmt mit dem gebrauchten loginhash
  final client = http.Client();

  // ignore: prefer_final_fields
  var _document = '';
  var loginhash = '';
  Map<String, String> _header = {};

  //Das sind die Variabeln des Headers für den body der Post Methode
  Map<String, String> mapHeader = {};
  var phpSecurityHeader;
  var longCodeHeader;

  //WebScraper Objekt -> Mit diesen kann man HTML in String Form in einen Tree verwandeln und danach die einzelnen Elemente herausfiltern oder die Inhalte dessen Attribute
  WebScraper webscraper = WebScraper();

  //Konstruktor
  WebScraperNesa();

  void start() async {
    await getLoginhash().then((value) => cookies());
    await send().then((value) => getHomeData());
  }

  Map<String, String> cookies() {
    String? res = _header['set-cookie'];
    phpSecurityHeader = res!.split(';')[0];
    longCodeHeader = res.split(';')[1].split(',')[1];

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
      'Host': 'ksh.nesa-sg.ch',
      'User-Agent': 'Dart/2.14 (dart:io)',
      'date': 'Sun, 17 Oct 2021 19:44:14 GMT',
      'content-length': '90',
      'strict-transport-security':
          'max-age=31536000; includeSubDomains; preload',
      'pragma': 'no-cache',
      'x-frame-options': 'deny, expires: Mon, 26 Jul 1997 05:00:00 GMT'
    };

    /*
    String stringHeader = _header.toString();
    stringHeader = stringHeader.substring(1, stringHeader.length);
    List listHeader = stringHeader.split(';');
    int counter = 0;
    try{
    for (var i in listHeader) {
      for (var v = 0; v < listHeader.length; v++) {
        print(i.toString());
        var res = i.toString().split(',');
        if (v.isEven || v == 0) {
          listHeader[v] = res[v];
        }else if (v.isOdd && v != 0){
          for (var i = 0; i < res.length; i++) {
            listHeader[v][i] = res[i];
          }
        }else{
          throw Exception('Fehler bei Umwandlung von stringHeader zu listHeader'); //TODO: Exception
        }
      }
    }}catch(e, stacktrace){
      print(e.toString() + stacktrace.toString());
    }*/
    //print('String Header -> ' + listHeader.toString());

    return result;
  }

  //Hinzufügen der variablen (nicht nur 'layout-size=md'; zum Beispiel nicht) Daten für die Cookies für den Header
  void addCookies() {
    String? res = _header['set-cookie'];

    phpSecurityHeader = res!.split(';')[0];

    longCodeHeader = res.split(';')[1].split(',')[1];

    if (phpSecurityHeader.isNotEmpty && longCodeHeader.isNotEmpty) {
      mapHeader['Cookies'] = phpSecurityHeader +
          '; Path=/, ' +
          longCodeHeader +
          '; Domain=ksh.nesa.sg.ch; Path=/';
    } else {
      throw Exception('Die Variabeln der für die addCookies Methode sind leer');
    }

    client.head(Uri.parse('https://ksh.nesa-sg.ch/loginto.php?mode=0&lang='));
  }

  void handleCookies(http.Client client) async {
    var cookieManager = WebviewCookieManager();
    var getCookie = await cookieManager;
  }

  //Hier wird die Login Seite von Nesa aufgerufen
  Future<String> getLoginhash() async {
    try {
      //Html von Login Page wird geholt
      var res = await client.post(
        Uri.parse('https://ksh.nesa-sg.ch/loginto.php?mode=0&lang='),
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

      //Überprüft, ob JavaScript aktiviert ist
      if (webscraper.getElement(
          '#standardformular > div > div:nth-child(3) > noscript > span',
          []).isNotEmpty) {
        throw Exception('JavaScript ist ausgeschalten');
        //#standardformular > div > div:nth-child(3) > noscript > span
      }

      //Loginhash

      loginhash = webscraper.getElementAttribute(
              '#standardformular > div > div.mdl-cell.mdl-cell--12-col > input',
              'value')[1]
          as String; //Der Webscraper gibt alles zurück, was auf die Beschreibung passt, deshalb wird hier nur das relavante also die 2. Stelle genommen (1.Stelle, da die Liste bei 0 anfängt)

      return loginhash;
    }
    return loginhash;
  }

  //Schickt die Benutzerdaten dem Post-Link, um durch das Login System zu passieren
  Future<void> send() async {
    //form beinhaltet alle Daten, die von nesa-sg.ch für den Login verlangt werden
    Map<String, String> form = {
      "login": "ajidan.jegatheeswaran",
      "passwort": "10Scheisse",
      "loginhash": loginhash
    };

    //Mittels Post Request werden die form Daten versendet
    var res = await client.post(
      Uri.parse('https://ksh.nesa-sg.ch/index.php?pageid=1'),
      headers: cookies(),
      body: form,
    );

    if (res.statusCode == 200) {
      _document = res.body;
    } else {
      throw Exception(
          'Status Code ist nicht 200, sondern ' + res.statusCode.toString());
    }
  }

  Future<String> _getPageContent(String link) async {
    var res = await client.get(Uri.parse(link));
    var content = res.body;
    return content;
  }

  String buildLink(String frag) {
    return 'https://ksh.nesa-sg.ch/' + frag;
  }

  //Holt alle Links der Navigation Bar
  Future<void> setNavigationPageContent(Enum c) async {
    bool _isLoad = webscraper.loadFromString(_document);

    String getNavigationPage() {
      String menu;

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
      return _getPageContent(buildLink(link.toString())).toString();
    }

    _isLoad = webscraper.loadFromString(getNavigationPage());
    if (!_isLoad) {
      throw Exception(); //TODO: Exception
    }
  }

  String formatSelector(String selector) {
    List<String> list = selector.split('>');
    for (String i in list) {
      i.replaceAll(' ', '');
    }
    String string = '';
    for (int i = 0; i < list.length; i++) {
      if (i == (list.length - 1)) {
        string += list[i];
      } else {
        string += list[i] + '>';
      }
    }
    print(string);
    return string.trim();
  }

  getHomeData() {
    setNavigationPageContent(NaviPage.home);
    var stringName = webscraper.getElement(
        formatSelector(
            '#content-card > div > div.mdl-d ata-table__cell--non-numeric > table > tbody > tr:nth-child(1) > td:nth-child(1)'),
        []);
    print(stringName);
  }

  //Schliesst den Client
  void closeClient() => client.close();
}
