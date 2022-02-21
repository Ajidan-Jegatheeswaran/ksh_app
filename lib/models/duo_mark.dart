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
    print('listDuoMarks');
    print(listDuoMarks);
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

    print('listObjectOfDuoMark');
    print(listObjectOfDuoMark);
    return listObjectOfDuoMark;
  }

  //Hinzufügen Funktion, welche eine Duo Note hinzufügt
  static Future<void> add(Map<String, dynamic> firstSubject,
      Map<String, dynamic> secondSubject, BuildContext context) async {
    /*List exist = await DuoMark.isExist(DuoMark(firstSubject, secondSubject));
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
    }*/

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
      print('marks');
      print(marks);
    }

    //Bei alle Fächer die von der Duo Note betroffen sind kommt ein true
    //Alle Fächer die ein true haben bekommen einen Eintrag, welches den duo Patner beinhaltet
    /*
    Map<String, dynamic> sub1 = {};
    Map<String, dynamic> sub2 = {};

    Map<String, dynamic> marks = await User.readFile(requiredFile.userMarks);
    List<Map<String, dynamic>> list =
        marks.values.toList() as List<Map<String, dynamic>>;
    Map<String, dynamic> newMapMarks = {};
    List newValues = [];
    for (Map<String, dynamic> i in marks.values) {
      bool isDuoNote = false;
      if (i['Fach'] == firstSubject['Fach'] ||
          i['Fach'] == secondSubject['Fach']) {
        isDuoNote = true;
      }
      i['isDuoNote'] = isDuoNote;
      newValues.add(i);
    }
    for (var i = 0; i < marks.length; i++) {
      newMapMarks[marks.keys.toList()[i]] = newValues[i];
    }
    print('NewMapMarks Duo Mark');
    print(newMapMarks);
    User.writeInToFile(newMapMarks, requiredFile.userMarks);
    */
    print('Add new Duo Mark...');
    print(data);
    await User.writeInToFile(data, requiredFile.userDuoMarks);
  }

  //Lösch Funktion
  static void delete(String subjectNames) async {
    Map<String, dynamic> data = await User.readFile(requiredFile.userDuoMarks);
    Map<String, dynamic> marks = await User.readFile(requiredFile.userMarks);
    print('Data Delete');
    print(data);
    String firstSubjectName = subjectNames.split(' + ')[0];
    print('deleteFirstName');
    print(firstSubjectName);
    String secondSubjectName = subjectNames.split(' + ')[1];
    print('deleteSecondName');
    print(secondSubjectName);
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
    
    print('Deleted DuoMarks');
    print(marks);
    User.writeInToFile(data, requiredFile.userDuoMarks);

    if (objectFound1 || objectFound2) {
      print('Objekt erfolgreich entfernt...');
    } else {
      print('Objekte konnte nicht entfernt werden...');
    }
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
