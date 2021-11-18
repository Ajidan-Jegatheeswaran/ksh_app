import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';

class NotRelevantMarksScreen extends StatefulWidget {
  static const routeName= '/not-relevant-mark-screen';

  @override
  State<NotRelevantMarksScreen> createState() => _NotRelevantMarksScreenState();
}

class _NotRelevantMarksScreenState extends State<NotRelevantMarksScreen> {
  var _selectedSubjectForSubmit;
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> mapOfSubjects = {};
    int _value = 0;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Notensaldo - Nicht Relevant'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      //bottomNavigationBar: ,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            print(mapOfSubjects);
            String subjectTitle = '';
            List<String> listOfSubjects = [];
            for (String item in mapOfSubjects.keys) {
              listOfSubjects.add(item);
            }
            subjectTitle = listOfSubjects[_value];
            print('Subjet Title');
            print(subjectTitle);
            String subjectName = _selectedSubjectForSubmit["Fach"];
            String subjectMark = _selectedSubjectForSubmit["Note"];
            String subjectIsTrue = _selectedSubjectForSubmit["Noten bestätigt"];

            mapOfSubjects[subjectTitle] =
                '{Fach: $subjectName, Note: $subjectMark, Noten bestätigt: $subjectIsTrue}';

            print('New Map');
            print(mapOfSubjects);

            User.writeInToFile(mapOfSubjects, requiredFile.userMarks);
          },
          child: const Icon(
            Icons.check,
            color: Colors.white,
          ),
          backgroundColor: Colors.green),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: FutureBuilder(
        future: User.readFile(requiredFile.userMarks),
        builder: (ctx, snap) {
          switch (snap.connectionState) {
            case ConnectionState.none:
              Center(child: CircularProgressIndicator());
              break;
            case ConnectionState.waiting:
              Center(child: CircularProgressIndicator());
              break;
          }

          final marks = snap.data;
          if (marks is Map) {
            print('Marks is a Map');
          }

          Map<String, dynamic> map =
              Map<String, dynamic>.from(snap.data as Map);
          print(map['D-4Wa-Rb']);

          mapOfSubjects = map;

          return ListView.builder(
            itemCount: 10,
            itemBuilder: (ctx, index) {
              var res = map.values.toList()[index];

              print(res);

              print('SelectedSubjectForSUbmit');
              print(_selectedSubjectForSubmit);

              String subjectName = _selectedSubjectForSubmit['Fach'];
              print('SubjectName');
              print(subjectName);
              return Container(
                margin: const EdgeInsets.only(top: 15, right: 15, left: 15),
                child: RadioListTile(
                  title: Text(
                    subjectName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _value = value as int;
                    });
                  },
                  groupValue: _value,
                  value: index,
                  tileColor: Theme.of(context).colorScheme.secondary,
                  activeColor: Theme.of(context).canvasColor,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
