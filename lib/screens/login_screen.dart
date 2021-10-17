import 'package:flutter/material.dart';
import 'package:ksh_app/screens/home_screen.dart';
import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(
        context); // MediaQuery wird hier als Objekt in der Variabel mediaQuery gespeichert, damit es zu weniger build() aufrufen kommt -> Performance
    
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
                          child: SingleChildScrollView(
                            child: Column(children: [
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Benutzername',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              TextFormField(
                                textInputAction: TextInputAction
                                    .send, //Achtung hier wurde send anstatt next verwendet bei Fehler hierauf achten
                                decoration: const InputDecoration(
                                  labelText: 'Passwort',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: mediaQuery.size.height * 0.05),
                                child: TextButton(
                                  onPressed: () {}, //todo: Implement Button
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
