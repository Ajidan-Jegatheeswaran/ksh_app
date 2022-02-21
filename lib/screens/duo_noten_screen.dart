import 'package:flutter/material.dart';
import 'package:ksh_app/models/duo_mark.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/screens/home_screen.dart';
import 'package:ksh_app/screens/not_relevant_marks_screen.dart';
import 'package:ksh_app/widgets/bottom_navigation_bar_widget.dart';
import 'package:ksh_app/widgets/duo_note_erstellen_select_widget.dart';

//Hier ist die Klasse, mit der zwei Noten zusammen für den Notensaldo gezählt werden.
class DuoNotenScreen extends StatefulWidget {
  static const routeName = '/noten-saldo-settings';

  @override
  State<DuoNotenScreen> createState() => _DuoNotenScreenState();
}

class _DuoNotenScreenState extends State<DuoNotenScreen> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    Map<String, dynamic> showDialogChooseSubject(Map<String, dynamic> marks) {
      Map<String, dynamic> selectedMark = {};
      int _groupValue = 1;

      void showDialogChooseSubjectSecond(
          Map<String, dynamic> lastSubject, Map<String, dynamic> marks) {
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
                      child: const Center(
                        child: Text('Wähle das zweite Fach aus',
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
                            print('SUbjectsList');
                            print(subjectsList);
                            Map<String, dynamic> subject =
                                Map<String, dynamic>.from(subjectsList[index]);
                            print('Subjectmap');
                            print(subject);
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
                                onTap: () async {
                                  DuoMark.add(lastSubject, subject, context);
                                  var a = await User.readFile(
                                      requiredFile.userDuoMarks);
                                  print(a);
                                  setState(() {});
                                  Navigator.of(context).popUntil(
                                    ModalRoute.withName(
                                        DuoNotenScreen.routeName),
                                  );
                                },
                              ),
                            );
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
      }

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
                    child: const Center(
                      child: Text('Wähle das erste Fach aus',
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
                          print('SUbjectsList');
                          print(subjectsList);
                          Map<String, dynamic> subject =
                              Map<String, dynamic>.from(subjectsList[index]);
                          print('Subjectmap');
                          print(subject);
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
                              onTap: () {
                                showDialogChooseSubjectSecond(subject, marks);
                              },
                            ),
                          );
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

    Future<Map<String, dynamic>> userData() async {
      Map<String, dynamic> userMarks =
          await User.readFile(requiredFile.userMarks);
      Map<String, dynamic> userDuoMarks =
          await User.readFile(requiredFile.userDuoMarks);
      return {'marks': userMarks, 'duoMarks': userDuoMarks};
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: const Text('Duo Noten'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        bottomNavigationBar: BottomNavigatioinBarWidget(),
        body: FutureBuilder(
          future: userData(),
          builder: (ctx, snap) {
            Map<String, dynamic> marks = {};
            Map<String, dynamic> duoMarks = {};
            try {
              Map<String, dynamic> _userData =
                  snap.data as Map<String, dynamic>;
              marks = _userData['marks'] as Map<String, dynamic>;
              duoMarks = _userData['duoMarks'] as Map<String, dynamic>;
              print('mARKS');
              print(marks);
            } catch (Exception) {
              print('Oh Exception');
            }
            return Padding(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Container(
                  color: Theme.of(context).colorScheme.secondary,
                  width: mediaQuery.width - 30,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Deine  Liste',
                            style: TextStyle(color: Colors.white),
                            textScaleFactor: 1.3,
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  mediaQuery = MediaQuery.of(context).size;
                                  return Dialog(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    insetPadding: const EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                        top: 140,
                                        bottom: 140),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(30),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                //todo: Farbe für Container einstellen und ListTile Farben zu primary machen
                                                width: mediaQuery.width - 30,
                                                child: const Center(
                                                  child: Text(
                                                    'Duo Note erstellen',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textScaleFactor: 1.3,
                                                  ),
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 30),
                                                child: Text(
                                                  'Manche Noten zählen gemeinsam für den Notensaldo '
                                                  'und dafür kannst du hier eine Duo Note erstellen. Beispielsweise Musik(4.5) und'
                                                  ' BG(3.5) zählen zusammen. D.h. zusammen gibt das einen Schnitt von 4, welcher einen '
                                                  'keinen Plus oder Minus Punkt für den Notensaldo einbringt. ',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  textScaleFactor: 1.2,
                                                ),
                                              )
                                            ],
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              showDialogChooseSubject(marks);
                                            },
                                            child: const Text('Erstellen'),
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.blue)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: duoMarks.length,
                          itemBuilder: (ctx, index) {
                            return Column(
                              children: [
                                Container(
                                  color: Theme.of(context).primaryColor,
                                  child: ListTile(
                                    title: Text(
                                      DuoMark.mapFromJson(duoMarks)[index],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          DuoMark.delete(DuoMark.mapFromJson(
                                              duoMarks)[index]);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10)
                              ],
                            );
                          })
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
