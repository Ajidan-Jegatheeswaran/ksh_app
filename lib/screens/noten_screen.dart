import 'package:flutter/material.dart';
import 'package:ksh_app/models/subject.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/screens/detail_noten_screen.dart';
import 'package:ksh_app/screens/home_screen.dart';
import 'package:ksh_app/widgets/bottom_navigation_bar_widget.dart';

import 'my_account_screen.dart';

// werden alle Fächer mit den jeweiligen Notenschnitten aufgelistet
class NotenScreen extends StatelessWidget {
  static const routeName = '/noten';
  late int _markLength;
  Future<Map<String, dynamic>> marks = User.readFile(requiredFile.userMarks);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        bottomNavigationBar: BottomNavigatioinBarWidget(),
        appBar: AppBar(
          title: const Text('Noten'),
          backgroundColor: Theme.of(context).primaryColor,
          
        ),
        body: FutureBuilder(
          future: marks,
          builder: (BuildContext ctx, AsyncSnapshot a) {
            switch (a.connectionState) {
              case ConnectionState.waiting:
                return Container();
              case ConnectionState.none:
                return Container();
              case ConnectionState.active:
                break;
              case ConnectionState.done:
                break;
            }
            Map<String, dynamic> userMarksMap = a.data;
            List<Subject> subjects = [];

            //Map wird in eine Liste umgewandelt
            for (int i = 0; i < userMarksMap.length; i++) {
              String subjectTitle = userMarksMap.keys.toList()[i];
              String subjectName = userMarksMap.values.toList()[i]['Fach'];
              String subjectMark = userMarksMap.values.toList()[i]['Note'];
           
              if(subjectMark.replaceAll(' ', '') == '--'){
                subjectMark = '0.0';
              }
              Subject subject = Subject(
                  title: subjectTitle,
                  name: subjectName,
                  mark: double.parse(subjectMark));
              subjects.add(subject);
            }

            return ListView.builder(
              itemCount: userMarksMap.length,
              itemBuilder: (BuildContext ctx, int index) {
                return Container(
                  color: Theme.of(context).colorScheme.secondary,
                  margin: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 10,
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        DetailNotenScreen.routeName,
                        arguments: {
                          'title': subjects[index].title,
                          'name': subjects[index].name,
                          'mark': subjects[index].toString(),
                        },
                      );
                    },
                    leading: Text(
                      subjects[index].name,
                      style: const TextStyle(color: Colors.white),
                      textScaleFactor: 1.4,
                    ),
                    trailing: Text(
                      subjects[index].markAsString(),
                      style: const TextStyle(color: Colors.white),
                      textScaleFactor: 1.4,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
