import 'package:http/http.dart' as http;

class WebScraper {
  final client = http.Client();
  //Allgemeine Variabeln
  final urlLoginPage = Uri.parse('https://ksh.nesa-sg.ch/');
  final urlForLogin = Uri.parse('https://ksh.nesa-sg.ch/loginto.php?pageid=&mode=14&lang=');

  
  Map<String, String> headers = {};

  void login() async {
    this.client.get(urlLoginPage, headers: headers);
    //var client = httpAuth.BasicAuthClient('ajidan.jegatheeswaran', '10Scheisse');
    var response = client.get(Uri.parse('https://ksh.nesa-sg.ch/loginto.php?pageid=&mode=14&lang='), headers: headers);

    print('Client: '+ client.toString() +
    'Response: ' + response.toString() +
    'headers: ' + headers.toString());
  }
}
