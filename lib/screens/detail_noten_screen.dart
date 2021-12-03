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
            print('Snap');
            print(snap.data);

            marksOfSubject = snap.data as Map<String, dynamic>;
            markSubject =
                List<Map<String, dynamic>>.from(marksOfSubject[subjectName]);
            print('MarkSubject');
            print(markSubject);

            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                  right: 15, left: 15, top: 3, bottom: 15),
              child: Column(
                children: [
                  const Text(
                    'Deine Daten',
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
                      if (markSubject[index]['valuation'].toString().trim() ==
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
                          contentPadding: EdgeInsets.only(left: 30, right: 30),
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
            );
          }),
    );
  }
}
