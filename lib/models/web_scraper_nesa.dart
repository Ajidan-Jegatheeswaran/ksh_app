// ignore_for_file: unrelated_type_equality_checks

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:web_scraper/web_scraper.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

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
  WebScraperNesa() {
    getLoginhash().then((value) {
      cookies();
      send();
    }).then((value) => getNavigator());
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
    print(result.toString());
    return result;
  }

  //Hinzufügen der variablen (nicht nur 'layout-size=md'; zum Beispiel nicht) Daten für die Cookies für den Header
  void addCookies() {
    String? res = _header['set-cookie'];
    print('print Cookie -> ' + _header.toString());
    phpSecurityHeader = res!.split(';')[0];
    print(phpSecurityHeader);
    longCodeHeader = res.split(';')[1].split(',')[1];
    print(longCodeHeader);
    if (phpSecurityHeader.isNotEmpty && longCodeHeader.isNotEmpty) {
      mapHeader['Cookies'] = phpSecurityHeader +
          '; Path=/, ' +
          longCodeHeader +
          '; Domain=ksh.nesa.sg.ch; Path=/';
    } else {
      throw Exception('Die Variabeln der für die addCookies Methode sind leer');
    }
    print('MapHeader: ' + mapHeader.toString());
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
      print('Resultat: ' + res.body);
      //Überprüfung, ob res.body leer ist
      if (res.body.isNotEmpty) {
        _document = res.body;
      } else if (res.body.isEmpty) {
        throw Exception('res.body von Login Page ist leer');
      } else {
        throw Exception();
      }
      _header = res.headers;
      print('Header -> ' + res.headers.toString());
    } on Error catch (error) {
      print('GetLogin -> Error');
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
      } else {
        print('JavaSript ist eingeschaltet');
      }

      //Loginhash
      print(webscraper.getElementAttribute(
          '#standardformular > div > div.mdl-cell.mdl-cell--12-col > input',
          'value'));

      loginhash = webscraper.getElementAttribute(
              '#standardformular > div > div.mdl-cell.mdl-cell--12-col > input',
              'value')[1]
          as String; //Der Webscraper gibt alles zurück, was auf die Beschreibung passt, deshalb wird hier nur das relavante also die 2. Stelle genommen (1.Stelle, da die Liste bei 0 anfängt)
      print('Loginhash 1: ' + loginhash);
      return loginhash;
    }
    return loginhash;
  }

  //Schickt die Benutzerdaten dem Post-Link, um durch das Login System zu passieren
  void send() async {
    //form beinhaltet alle Daten, die von nesa-sg.ch für den Login verlangt werden
    Map<String, String> form = {
      "login": "ajidan.jegatheeswaran",
      "passwort": "10Scheisse",
      "loginhash": loginhash
    };

    print('Loginhash 2: ' + loginhash);
    //print('Headers -> ' + headers);
    //Mittels Post Request werden die form Daten versendet
    var res = await client.post(
      Uri.parse('https://ksh.nesa-sg.ch/index.php?pageid=1'),
      headers: cookies(),
      body: form,
    );

    if (res.statusCode == 200) {
      _document = res.body;
      print(_document);
    } else {
      throw Exception(
          'Status Code ist nicht 200, sondern ' + res.statusCode.toString());
    }
  }

  getNavigator() {
    bool _isLoad = webscraper.loadFromString(_document);
    if (_isLoad) {
      var linkHomePage = webscraper.getElementAttribute('#nav-main-menu > a', 'href');
    print(linkHomePage);
    }

  }

  //Schliesst den Client
  void closeClient() => client.close();
}

//Lösung von Richard Heap -> Verbesserte Version nicht von mir, sondern... -> Quellen: https://newbedev.com/how-do-i-make-an-http-request-using-cookies-on-flutter oder https://stackoverflow.com/questions/52241089/how-do-i-make-an-http-request-using-cookies-on-flutter
//Diese Klasse wird von mir vorallem für das Handeln der Cookies verwendet
/*class NetworkService {
  final JsonDecoder _decoder = new JsonDecoder();
  final JsonEncoder _encoder = new JsonEncoder();

  

  void _updateCookie(http.Response response) {
    String allSetCookie = response.headers['set-cookie'] as String;

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }

      headers['cookie'] = _generateCookieHeader();
    }
  }

  void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];

        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires') return;

        this.cookies[key] = value;
      }
    }
  }

  String _generateCookieHeader() {
    String cookie = "";

    for (var key in cookies.keys) {
      if (cookie.length > 0) cookie += ";";
      cookie += key + "=" + cookies[key].toString();
    }

    return cookie;
  }

  Future<dynamic> get(String url) {
    return http
        .get(Uri.parse(url), headers: headers)
        .then((http.Response response) {
      //Leichte Änderung von mir aufgrund von Neuerung von Flutter aus, welche nicht hier beachtet/aktualisiert wurden -> Uri.parse()
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, {body, encoding}) {
    //Da mein HTML Code einen Format Fehler hat, muss die Methode angepasst werden
    String handleFormatError(String html) {
      if (html.startsWith('<')) {
        String newHtml = html.substring(1);
        return newHtml;
      }
      return html;
    }

    if (body is String) {
      return http
          .post(Uri.parse(url),
              body: _encoder.convert(handleFormatError(body.toString())),
              headers: headers,
              encoding:
                  encoding) //Leichte Änderung von mir aufgrund von Neuerung von Flutter aus, welche nicht hier beachtet/aktualisiert wurden -> Uri.parse()
          .then((http.Response response) {
        final String res = response.body;
        final int statusCode = response.statusCode;

        _updateCookie(response);

        if (statusCode < 200 || statusCode > 400 || json == null) {
          throw new Exception("Error while fetching data");
        }
        return _decoder.convert(res);
      });
    }
    throw Exception('Post hat nicht funktioniert'); //TODO: Error besser handeln
  }
}*/
