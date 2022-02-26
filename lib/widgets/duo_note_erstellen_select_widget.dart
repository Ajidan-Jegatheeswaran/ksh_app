import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';

class DuoNoteErstellenSelectWidget extends StatefulWidget {
  final String text;

  DuoNoteErstellenSelectWidget(this.text);

  @override
  State<DuoNoteErstellenSelectWidget> createState() =>
      _DuoNoteErstellenSelectWidgetState();
}

class _DuoNoteErstellenSelectWidgetState
    extends State<DuoNoteErstellenSelectWidget> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    Map<String, dynamic> showDialogChooseSubject(Map<String, dynamic> marks) {
      Map<String, dynamic> selectedMark = {};
      int _groupValue = 1;

      showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            //shape: RoundedRectangleBorder(
            //borderRadius: BorderRadius.circular(40),
            //),
            insetPadding: EdgeInsets.all(10),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: mediaQuery.height * 0.1,
                    child: Center(
                      child: Text('Erstelle ein Duo Noten',
                          style: TextStyle(color: Colors.white),
                          textScaleFactor: 1.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Flexible(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: marks.length,
                        itemBuilder: (ctx, index) {
                          List<dynamic> subjectsList = marks.values.toList();
                          
                          Map<String, dynamic> subject =
                              Map<String, dynamic>.from(subjectsList[index]);
                        
                          bool isRadioSelcted = false;
                          int _value = 0;
                          return Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: ListTile(
                              title: Text(
                                subject['Fach'],
                                style: const TextStyle(color: Colors.white),
                              ),
                              tileColor: Theme.of(context).primaryColor,
                              onTap: () {},
                            ),
                          );
                          /*
                          return Container(
                            padding:
                                EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
                            color: Theme.of(context).primaryColor,
                            child: Column(
                              children: [
                                Container(
                                  color: Theme.of(context).colorScheme.secondary,
                                  child: RadioListTile(
                                    title: Text(
                                      subject['Fach'],
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    onChanged: (val) {
                                      //selectedMark = val as Map<String, dynamic>;
                                      print('Value');
                                      print(val);
                                      setState(() {
                                        _value = val as int;
                                      });
                                    },
                                    groupValue: _value,
                                    value: index,
                                    activeColor: Theme.of(context).canvasColor,
                                    tileColor: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          );*/
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return selectedMark;
    }

    return FutureBuilder(
        future: User.readFile(requiredFile.userMarks),
        builder: (ctx, snap) {
          Map<String, dynamic> marks = {};
          try {
            marks = snap.data as Map<String, dynamic>;
          
          } catch (Exception) {
          
          }

          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              margin: const EdgeInsets.only(top: 15),
              color: Theme.of(context).primaryColor,
              height: mediaQuery.height * 0.3,
              width: mediaQuery.width - 30,
              child: Center(
                child: TextButton(
                  onPressed: () {
                    showDialogChooseSubject(marks);
                  },
                  child: const Text(
                    'Auswählen',
                    textScaleFactor: 1.3,
                  ),
                ),
              ),
            ),
          );
        });
  }
}
