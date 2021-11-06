import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/models/web_scraper_nesa.dart';
import 'package:ksh_app/screens/home_screen.dart';
import 'package:ksh_app/screens/noten_screen.dart';
import 'package:path_provider/path_provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  // ignore: prefer_final_fields
  Map<String, dynamic> _userData = {
    'username': '',
    'password': '',
    'host': 'ksh'
  };

  //File Variabeln
  late Directory dir;
  late File jsonFile;
  late Map<String, dynamic> fileContent;
  final String fileName = 'userData.json';
  bool fileExists = false;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = File(dir.path + '/' + fileName);
      fileExists = jsonFile.existsSync();
      /*if (fileExists) {
        _userData = convert.jsonDecode((jsonFile.readAsStringSync()));
      }*/
    });
  }

  void saveLoginDataInStorage() {
    if (fileExists) {
      jsonFile.deleteSync();
    }
    jsonFile.createSync();
    fileExists = true;
    jsonFile.writeAsStringSync(convert.jsonEncode(_userData));
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(
        context); // MediaQuery wird hier als Objekt in der Variabel mediaQuery gespeichert, damit es zu weniger build() aufrufen kommt -> Performance

    void _submit() async {
      print('Submit');
      if (!_formKey.currentState!.validate() && _userData['host'] == '') {
        throw Exception(); //todo: Exception
      }
      _formKey.currentState!.save();

      print(
          _userData['username'].toString() + _userData['password'].toString());

      User.writeInToFile(_userData, requiredFile.userLogin); //todo: Durch User Methode ersetzen

      WebScraperNesa webScraper = WebScraperNesa(
          username: _userData['username'].toString(),
          password: _userData['password'].toString(),
          host: _userData['host'].toString());

      bool isUserLogin = await User.getUserData(webScraper);

      print(isUserLogin);
      if (isUserLogin) {
        print('If isLogin -> True');
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: [
          Padding(
            child: Text(
              'Anmelden',
              style: Theme.of(context).textTheme.headline6,
            ),
            padding: EdgeInsets.only(
                top: mediaQuery.size.height * 0.1,
                bottom: mediaQuery.size.height * 0.1),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Card(
                color: Theme.of(context).colorScheme.secondary,
                child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image.asset(
                              'assets/img/kanton_sg_wappen.png',
                              width: 30,
                            ),
                            SizedBox(
                              width: mediaQuery.size.width * 0.2,
                            ),
                            const Text(
                              'Nesa Login',
                              textAlign: TextAlign.right,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            )
                          ],
                        ),
                        SizedBox(
                          height: mediaQuery.size.height * 0.025,
                        ),

                        //Formular für das Login
                        Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(children: [
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Benutzername',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (val) {
                                  if (val == '' || val == Null) {
                                    return 'Bitte geben Sie Ihren Benutzernamen ein.';
                                  }
                                },
                                onSaved: (val) {
                                  _userData['username'] = val.toString();
                                },
                              ),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Passwort',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                style: const TextStyle(color: Colors.white),
                                obscureText: true,
                                validator: (val) {
                                  if (val == '' || val == Null) {
                                    return 'Bitte geben Sie ein Passwort ein.';
                                  }
                                },
                                onSaved: (val) =>
                                    {_userData['password'] = val.toString()},
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: mediaQuery.size.height * 0.05),
                                child: TextButton(
                                  onPressed: _submit,
                                  child: const Text(
                                    'Anmelden',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.purple),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
