import 'package:flutter/material.dart';
import 'package:ksh_app/models/subject.dart';
import 'package:ksh_app/models/user.dart';

//Enum, welche das definieren der angezeigten Information einfacher machen für den Programmierer und für andere Programmierer lesbarer machen.
enum shownDataEnum { saldo, notenschnitt, openAbsence, fach }

class ListTileInformationWidget extends StatelessWidget {
  late String title;
  String shownData;
  late Enum mode;

  Map<String, dynamic> _userData = {};

  ListTileInformationWidget(this.mode,
      {this.title = 'None', this.shownData = 'None'});

  Future<Map<String, dynamic>> userData =
      User.readFile(requiredFile.userDashboard);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    return FutureBuilder(
        future: userData,
        builder: (BuildContext ctx, AsyncSnapshot<dynamic> asyncSanpshot) {
          //Hier werden alle Szenarien aufgelistet, sodass später durch eine einfache Angabe der angezeigten Information über ein Enum der richtigige Code ausgeführt wird.
          if (const AsyncSnapshot.nothing() == asyncSanpshot ||
              const AsyncSnapshot.waiting() == asyncSanpshot) {
                return CircularProgressIndicator();
          } else {
            switch (mode) {
              case shownDataEnum.saldo:
                title = 'Dein Saldo';
                
                shownData = asyncSanpshot.data['saldo'][0].toString();
                break;
              case shownDataEnum.notenschnitt:
                title = 'Akuteller Notenschnitt';
                String _shownDataVal = asyncSanpshot.data['notenschnitt'][1].toString();
                if(_shownDataVal.length > 4){
                  shownData = _shownDataVal.substring(0,4);
                }else{
                  shownData = _shownDataVal;
                }
                break;
              case shownDataEnum.openAbsence:
                title = 'Offene Absenzen';
                shownData = asyncSanpshot.data['openAbsence'];
                break;
              case shownDataEnum.fach:
                if (true) {
                  throw Exception(
                      'Titel des Fachs und die Note fehlen.'); //todo: Exception
                }
             
              default:
                throw Exception(); //todo: Exception
            }

            return Column(
              children: [
                SizedBox(
                  height: mediaQuery.height * 0.012,
                ),
                ListTile(
                  minLeadingWidth: mediaQuery.width * 0.14,
                  tileColor: Theme.of(context).colorScheme.secondary,
                  leading: Icon(
                    Icons.school_outlined,
                    color: Colors.white,
                    size: mediaQuery.height * 0.046,
                  ),
                  title: Text(
                    title,
                    textScaleFactor: 1,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: Text(
                    shownData,
                    textScaleFactor: 1.4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }
        });
  }
}
