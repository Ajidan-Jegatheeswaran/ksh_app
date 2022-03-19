import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';

//Das ist der detallierter Fach Bildschirm, indem man die Einzelnnotne sieht
class DetailNotenScreen extends StatelessWidget {
  static const routeName = '/detail-noten';
  Future<Map<String, dynamic>> marksOfSubjectFuture =
      User.readFile(requiredFile.userAllMarks);
  Map<String, dynamic> marksOfSubject = {};
  List<Map<String, dynamic>> markSubject = [];

  @override
  Widget build(BuildContext context) {
    var screenData = ModalRoute.of(context)!.settings.arguments! as Map;
    String subjectName = screenData['name'];
    var mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(subjectName),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
          future: marksOfSubjectFuture,
          builder: (ctx, snap) {
            switch (snap.connectionState) {
              case ConnectionState.waiting:
                return Container();
              case ConnectionState.none:
                return Container();
              case ConnectionState.active:
                break;
              case ConnectionState.done:
                break;
            }

            marksOfSubject = snap.data as Map<String, dynamic>;
            if (marksOfSubject[subjectName] == Null) {
              return Container();
            }
            try {
              markSubject =
                  List<Map<String, dynamic>>.from(marksOfSubject[subjectName]);
            } catch (e) {
              return const Center(
                child: Text(
                  'Keine Noten vorhanden.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            String markRequiredForBetterGrading() {
              double akutellerNotenschnitt = double.parse(screenData['mark']);

              //Herausfinden, welche Note die nächstbessere ist.
              double aktuellerNotenschnittGerundet =
                  User.round(akutellerNotenschnitt);
              double nextBeterGrading = aktuellerNotenschnittGerundet +
                  0.25; //0.25 und nicht 0.5, weil es, dann gerundet die nächste Besser Note ergeben soll

              //Note herausfinden, welche es braucht, um diese Note zu erreichen
              double notensumme = nextBeterGrading * (markSubject.length + 1);

              for (int i = 0; i < markSubject.length; i++) {
                String markString =
                    markSubject[i]['valuation'].replaceAll(' ', '');
                if (markString == '') {
                  notensumme = notensumme - nextBeterGrading;
                  continue;
                }
                double mark = 0.0;
                try {
                  mark = double.parse(markSubject[i]['valuation']);
                } on FormatException {
                  notensumme = notensumme - nextBeterGrading;
                  continue;
                }
                notensumme = notensumme - mark;
              }

              if (notensumme > 6) {
                return 0.0.toString();
              }
              String result = notensumme.toString();
              return result;
            }

            String markRequiredForSameGrading() {
              //Herausfinden, welche der nächst schelchtere Notenschnitt ist
              double akutellerNotenschnitt = double.parse(screenData['mark']);
              double aktuellerNotenschnittGerundet =
                  User.round(akutellerNotenschnitt);
              double nextBeterGrading = aktuellerNotenschnittGerundet - 0.25;
              //Welche Note muss erreicht werden muss, um diesen Schnitt zu haben
              //Note herausfinden, welche es braucht, um diese Note zu erreichen
              double notensumme = nextBeterGrading * (markSubject.length + 1);

              for (int i = 0; i < markSubject.length; i++) {
                String markString =
                    markSubject[i]['valuation'].replaceAll(' ', '');
                if (markString == '') {
                  notensumme = notensumme - nextBeterGrading;
                  continue;
                }
                double mark = 0.0;
                try {
                  mark = double.parse(markSubject[i]['valuation']);
                } on FormatException {
                  notensumme = notensumme - nextBeterGrading;
                  continue;
                }
                notensumme = notensumme - mark;
              }

              if (notensumme > 6) {
                return 0.0.toString();
              }
              String result = notensumme.toString();
              return result;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                  right: 15, left: 15, top: 3, bottom: 15),
              child: Column(
                children: [
                  
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: mediaQuery.width * 0.45,
                        height: mediaQuery.height * 0.2,
                        color: Theme.of(context).colorScheme.secondary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              'Notenschnitt behalten',
                              style: TextStyle(color: Colors.white),
                              textScaleFactor: 1.1,
                            ),
                            Text(
                              markRequiredForSameGrading() == '0.0'
                                  ? 'Note > 6'
                                  : (markRequiredForSameGrading().length > 4
                                      ? markRequiredForSameGrading()
                                          .substring(0, 4)
                                      : markRequiredForSameGrading()),
                              style: const TextStyle(color: Colors.white),
                              textScaleFactor: 1.5,
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: mediaQuery.width * 0.45,
                        height: mediaQuery.height * 0.2,
                        color: Theme.of(context).colorScheme.secondary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              'Notenschnitt verbessern',
                              style: TextStyle(color: Colors.white),
                              textScaleFactor: 1.1,
                            ),
                            Text(
                              markRequiredForBetterGrading() == '0.0'
                                  ? 'Note > 6'
                                  : (markRequiredForBetterGrading().length > 4
                                      ? markRequiredForBetterGrading()
                                          .substring(0, 4)
                                      : markRequiredForBetterGrading()),
                              style: const TextStyle(color: Colors.white),
                              textScaleFactor: 1.5,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    'Deine Noten',
                    style: TextStyle(color: Colors.white),
                    textScaleFactor: 1.3,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: markSubject.length,
                      itemBuilder: (ctx, index) {
                        String toProve = markSubject[index]['valuation']
                            .toString()
                            .replaceAll(' ', '');
                        if (markSubject[index]['valuation'].toString().trim() ==
                            '') {
                          return Container(
                            width: 0,
                            height: 0,
                          );
                        }
                        if (markSubject[index]['valuation']
                            .toString()
                            .replaceAll(' ', '')
                            .contains('DetailszurNote')) {
                          String res = markSubject[index]['valuation']
                              .toString()
                              .replaceAll(' ', '');
                          String fixed = res
                              .split('DetailszurNote')[0]
                              .replaceAll(' ', '');
                          markSubject[index]['valuation'] = fixed;
                        }
                        return Container(
                          margin: EdgeInsets.only(bottom: 5),
                          color: Theme.of(context).colorScheme.secondary,
                          child: ListTile(
                            contentPadding:
                                EdgeInsets.only(left: 30, right: 30),
                            leading: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.adjust,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                            minLeadingWidth: 50,
                            title: Text(
                              markSubject[index]['topic'],
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Opacity(
                              opacity: 0.7,
                              child: Text(
                                markSubject[index]['date'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            trailing: Text(
                              markSubject[index]['valuation'],
                              style: const TextStyle(color: Colors.white),
                              textScaleFactor: 1.3,
                            ),
                          ),
                        );
                      })
                ],
              ),
            );

            /*
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        right: 15, left: 15, top: 3, bottom: 15),
                    child: Column(
                      children: [
                        const Text(
                          'Deine Noten',
                          style: TextStyle(color: Colors.white),
                          textScaleFactor: 1.5,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: markSubject.length,
                          itemBuilder: (ctx, index) {
                            if (markSubject[index]['valuation']
                                    .toString()
                                    .trim() ==
                                '') {
                              return Container(
                                width: 0,
                                height: 0,
                              );
                            }
                            return Container(
                              margin: EdgeInsets.only(bottom: 5),
                              color: Theme.of(context).colorScheme.secondary,
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.only(left: 30, right: 30),
                                leading: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Icon(
                                    Icons.adjust,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                                minLeadingWidth: 50,
                                title: Text(
                                  markSubject[index]['topic'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Opacity(
                                  opacity: 0.7,
                                  child: Text(
                                    markSubject[index]['date'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                trailing: Text(
                                  markSubject[index]['valuation'],
                                  style: const TextStyle(color: Colors.white),
                                  textScaleFactor: 1.3,
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  );*/
          }),
    );
  }
}
