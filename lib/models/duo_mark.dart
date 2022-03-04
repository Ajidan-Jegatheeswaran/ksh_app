import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';

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

  //Funktion macht eine Map mit den Daten der Klasse in Form eines Stringes
  Map<String, dynamic> toJson() {
    return {firstSubject.toString(): secondSubject.toString()};
  }

  //Wandelt den JSON in eine Map um
  static List<String> mapFromJson(Map<String, dynamic> map) {
    List listDuoMarks = map.values.toList();
    
    
    List listS1 = [];
    List listS2 = [];
    List<String> listObjectOfDuoMark = [];
    for (var i in listDuoMarks) {
      listS1.add(i.keys.first
          .toString()
          .replaceAll('{Fach: ', '')
          .replaceAll('}', '')
          .split(',')[0]);
    }
    for (Map i in listDuoMarks) {
      listS2.add(i.values.first
          .toString()
          .replaceAll('{Fach: ', '')
          .replaceAll('}', '')
          .split(',')[0]);
    }
    for (var i = 0; i < listS1.length; i++) {
      listObjectOfDuoMark.add(listS1[i] + ' + ' + listS2[i]);
    }

    return listObjectOfDuoMark;
  }

  //Hinzufügen Funktion, welche eine Duo Note hinzufügt
  static Future<void> add(Map<String, dynamic> firstSubject,
      Map<String, dynamic> secondSubject, BuildContext context) async {
 
    Map<String, dynamic> data = await User.readFile(requiredFile.userDuoMarks);
    data.addAll({
      firstSubject['Fach'] + secondSubject['Fach']:
          DuoMark(firstSubject, secondSubject).toJson()
    });

    //Laden der Fächer
    Map<String, dynamic> marks = await User.readFile(requiredFile.userMarks);
    for (var item in marks.entries.toList()) {
      Map<String, dynamic> value = Map<String, dynamic>.from(item.value);
      String key = item.key;
      if (value['Fach'].contains(firstSubject['Fach'])) {
        value['duoMark'] = true;
        value['duoPartner'] = secondSubject['Fach'];
      } else if (value['Fach'].contains(secondSubject['Fach'])) {
        value['duoMark'] = true;
        value['duoPartner'] = firstSubject['Fach'];
      }
      marks[key] = value;
      await User.writeInToFile(marks, requiredFile.userMarks);
     
      
    }

    Map<String,dynamic> userDashboard = await User.readFile(requiredFile.userDashboard);
      List<String> saldo = await User.saldo(marks);
      userDashboard['saldo'] = saldo;

    User.writeInToFile(userDashboard, requiredFile.userDashboard);

    await User.writeInToFile(data, requiredFile.userDuoMarks);
  }

  //Lösch Funktion
  static Future<void> delete(String subjectNames) async {
    Map<String, dynamic> data = await User.readFile(requiredFile.userDuoMarks);
    Map<String, dynamic> marks = await User.readFile(requiredFile.userMarks);
  
    String firstSubjectName = subjectNames.split(' + ')[0];
   
    String secondSubjectName = subjectNames.split(' + ')[1];
   
    bool objectFound1 = false;
    bool objectFound2 = false;

    data.remove(firstSubjectName + secondSubjectName) == Null
        ? objectFound1 = false
        : objectFound1 = true;

    data.remove(secondSubjectName + firstSubjectName) == Null
        ? objectFound2 = false
        : objectFound2 = true;

    
    for (var item in marks.entries.toList()) {
      String key = item.key;
      Map<String, dynamic> val = Map<String, dynamic>.from(item.value);
      if (val['Fach'].contains(firstSubjectName) ||
          val['Fach'].contains(secondSubjectName)) {
        val['duoMark'] = false;
        val['duoPartner'] = 'None';
        marks[key] = val;
      }
    }
    await User.writeInToFile(marks, requiredFile.userMarks);

    Map<String,dynamic> userDashboard = await User.readFile(requiredFile.userDashboard);
      List<String> saldo = await User.saldo(marks);
      userDashboard['saldo'] = saldo;

    User.writeInToFile(userDashboard, requiredFile.userDashboard);

    User.writeInToFile(data, requiredFile.userDuoMarks);

  }

  //Überprüft, ob die DuoNote existiert
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
