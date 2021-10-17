// ignore_for_file: unrelated_type_equality_checks
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:web_scraper/web_scraper.dart';

class WebScraperNesa {
  //Hier wird der Client gestartet, damit der loginhash für den Login übereinstimmt mit dem gebrauchten loginhash
  final client = http.Client();

  // ignore: prefer_final_fields
  var _document = '';
  var loginhash = '';
  Map<String, String> _header = {};

  //Das sind die Variabeln des Headers für den body der Post Methode
  Map<String, String> mapHeader = {
    "Content-Type": "application/x-www-form-urlencoded",
    "Connection": "keep-alive",
    "User-Agent": "Dart/2.14 (dart:io)" //Dart/2.14 (dart:io)
  };
  String phpSecurityHeader = '';
  String longCodeHeader = '';

  //WebScraper Objekt -> Mit diesen kann man HTML in String Form in einen Tree verwandeln und danach die einzelnen Elemente herausfiltern oder die Inhalte dessen Attribute
  WebScraper webscraper = WebScraper();

  //Konstruktor
  WebScraperNesa() {
    getLoginhash().then((value) {
      addCookies();
      send();
    }).then((value) => closeClient());
  }

  //Hinzufügen der variablen (nicht nur auch 'layout-size=md';) Daten für die Cookies für den Header
  void addCookies() {
    String? stringPhpSecurityHeader = _header['set-cookie'];
    phpSecurityHeader = 'set-cookie : ' + stringPhpSecurityHeader!;
    print('Print: ' + phpSecurityHeader);
    if (phpSecurityHeader.isNotEmpty && longCodeHeader.isNotEmpty) {
      mapHeader['Cookie'] =
          'layout-size=md; ' + phpSecurityHeader + '; ' + longCodeHeader;
    } else {
      throw Exception('Die Variabeln der für die getCookies Methode sind leer');
    }
  }

  //Hier wird die Login Seite von Nesa aufgerufen
  Future<String> getLoginhash() async {
    try {
      //Html von Login Page wird geholt
      var res = await client.post(
        Uri.parse('https://ksh.nesa-sg.ch/index.php?pageid=1'),
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

      /*loginhash = webscraper.getElementAttribute(
              '#standardformular > div > div.mdl-cell.mdl-cell--12-col > input',
              'value')[1]
          as String; */ //Der Webscraper gibt alles zurück, was auf die Beschreibung passt, deshalb wird hier nur das relavante also die 2. Stelle genommen (1.Stelle, da die Liste bei 0 anfängt)
      print('Loginhash 1: ' + loginhash);
      return loginhash;
    }
    return loginhash;
  }

  //Schickt die Benutzerdaten dem Post-Link, um durch das Login System zu passieren
  void send() async {
    //form beinhaltet alle Daten, die von nesa-sg.ch für den Login verlangt werden
    Map<dynamic, dynamic> form = {
      "login": "ajidan.jegatheeswaran",
      "passwort": "10Scheisse",
      "loginhash": loginhash
    };

    print('Loginhash 2: ' + loginhash);

    print('Cookies -> ');
    //print('Headers -> ' + headers);
    //Mittels Post Request werden die form Daten versendet
    var res = await client.post(
        Uri.parse('https://ksh.nesa-sg.ch/loginto.php?pageid=&mode=14&lang='),
        headers: mapHeader,

        /*{
          'Accept':
           //   'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/ //*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        //'Accept-Encoding': 'gzip, deflate, br',
        //'Accept-Language': 'de,de-DE;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
        //'Cache-Control': 'max-age=0',
        //'Connection': 'keep-alive',
        //'Cookie':
        //    'layout-size=md; menuHidden=0; PHPSESSID=snp2lll5vjcm0to1p9a1sva1ni; TS015cda4e=01260b303711143554f16b17ac986b2edb757ed95542a8bd04030c28081fc5a1589a6c6a526dc1e27f9dde2f5f395256ca8b149f85dc015c1e7b0122bc1c0249d6595842184aaaccc415245ce8d5fc7c04fbad338b',
        //'Host': 'ksh.nesa-sg.ch',
        //'Referer': 'https://www.google.com/',
        //'sec-ch-ua':
        //    '"Chromium";v="94", "Microsoft Edge";v="94", ";Not A Brand";v="99"',
        //'sec-ch-ua-mobile': '?0',
        //'sec-ch-ua-platform': '"Windows"',
        //'Sec-Fetch-Dest': 'document',
        //'Sec-Fetch-Mode': 'navigate',
        //'Sec-Fetch-Site': 'cross-site',
        //'Sec-Fetch-User': '?1',
        //'Upgrade-Insecure-Requests': '1',
        //'User-Agent':
        //    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36 Edg/94.0.992.47'
        //},
        body: form,
        encoding: convert.Encoding.getByName('UTF-8'));

    if (res.statusCode == 200) {
      print(res.body);
      print('Status Code: ' + res.statusCode.toString());
    } else {
      throw Exception(
          'Status Code ist nicht 200, sondern ' + res.statusCode.toString());
    }

    //Nun wird der Html Code ausgewertet
    //webscraper.loadFromString();

    var urlNoten = webscraper.getElementAttribute('a', 'href');
    print(urlNoten);
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
