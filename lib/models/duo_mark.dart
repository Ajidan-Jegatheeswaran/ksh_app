import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/screens/noten_saldo_settings_screen.dart';

class DuoMark {
  final Map<String, dynamic> firstSubject;
  final Map<String, dynamic> secondSubject;

  DuoMark(this.firstSubject, this.secondSubject);

  static bool isSubjectsDoubled(DuoMark d1, DuoMark d2) {
    bool isTrue = false;
    if (d1.firstSubject == d2.firstSubject ||
        d1.firstSubject == d2.secondSubject) {
      isTrue = true;
    } else if (d1.secondSubject == d2.firstSubject ||
        d1.secondSubject == d2.secondSubject) {
      isTrue = true;
    }
    return isTrue;
  }

  static Future<void> add(Map<String, dynamic> firstSubject,
      Map<String, dynamic> secondSubject, BuildContext context) async {
    List exist = await DuoMark.isExist(DuoMark(firstSubject, secondSubject));
    if (exist[0] || exist[1]) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text(
                    'Du hast zu einem der gewählten Fächer schon eine Duo Note erstellt'),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                          context, NotenSaldoSettingScreen.routeName),
                      child: Text('Verstanden'))
                ],
              )); //todo: Das noch testen
    }
    Map<String, dynamic> data = await User.readFile(requiredFile.userDuoMarks);
    data[firstSubject['Fach'] + secondSubject['Fach']] =
        DuoMark(firstSubject, secondSubject);
    print('Add new Duo Mark...');
    print(data);
    User.writeInToFile(data, requiredFile.userDuoMarks);
  }

  Future<void> delete(DuoMark d) async {
    Map<String, dynamic> data = await User.readFile(requiredFile.userDuoMarks);
    if (data.keys.contains(d.firstSubject['Fach'] + d.secondSubject['Fach'])) {
      data.remove(d.firstSubject['Fach'] + d.secondSubject['Fach']);
    } else if (data.keys
        .contains(d.secondSubject['Fach'] + d.firstSubject['Fach'])) {
      data.remove(d.secondSubject['Fach'] + d.firstSubject['Fach']);
    }
  }

  static Future<List> isExist(DuoMark d) async {
    Map<dynamic, dynamic> data = await User.readFile(requiredFile.userDuoMarks);
    bool isFirstSubject = false;
    bool isSecondSubject = false;
    for (String i in data.keys) {
      if (i.contains(d.firstSubject['Fach'])) {
        isFirstSubject = true;
      }
      if (i.contains(d.secondSubject['Fach'])) {
        isSecondSubject = true;
      }
    }
    return [isFirstSubject, isSecondSubject];
  }
}
