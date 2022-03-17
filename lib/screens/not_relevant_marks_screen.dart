import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Hier können alle nicht-relevanten Noten ausgewählt werden, damit der Notensaldo diese nicht zählt
class NotRelevantMarksScreen extends StatefulWidget {
  static const routeName = '/not-relevant-marks';

  @override
  State<NotRelevantMarksScreen> createState() => _NotRelevantMarksScreenState();
}

class _NotRelevantMarksScreenState extends State<NotRelevantMarksScreen> {
  var _selectedSubjectForSubmit;
  List<bool> isChecked = [];
  List<String> titles = [];
  Map<String, bool> notRelevantMarks = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Notensaldo - Nicht relevante Noten'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Die isChecked List in notRelevantsMark eintragen
          for(int i = 0; i < notRelevantMarks.length; i++){
            String notRelevantMarksKey = notRelevantMarks.keys.toList()[i];
            bool notRelevantMarksRelevant = isChecked[i];
            notRelevantMarks[notRelevantMarksKey] = notRelevantMarksRelevant;
          }

          //In File speichern
          await User.saveNotRelevantMarks(notRelevantMarks);

          setState(() {});
          Navigator.of(context).pushNamedAndRemoveUntil(
            HomeScreen.routeName,
            ModalRoute.withName(HomeScreen.routeName),
          );
        },
        child: Icon(Icons.check),
        backgroundColor: Theme.of(context).canvasColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FutureBuilder(
        future: User.readNotRelevantMarks(),
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

          notRelevantMarks = snap.data as Map<String, bool>;

          isChecked = notRelevantMarks.values.toList();
          titles = notRelevantMarks.keys.toList();

          //Den Status der Nicht Relevanten Noten durch iterieren

          return SingleChildScrollView(
            child: Column(
              children: [
                ListViewBuilderForCheckBoxNotRelevantMarks(
                    marks: notRelevantMarks,
                    isChecked: isChecked,
                    titles: titles),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ListViewBuilderForCheckBoxNotRelevantMarks extends StatefulWidget {
  const ListViewBuilderForCheckBoxNotRelevantMarks(
      {Key? key,
      required this.marks,
      required this.isChecked,
      required this.titles})
      : super(key: key);

  final Map<String, dynamic> marks;
  final List<bool> isChecked;
  final List<String> titles;

  @override
  State<ListViewBuilderForCheckBoxNotRelevantMarks> createState() =>
      _ListViewBuilderForCheckBoxNotRelevantMarksState();
}

class _ListViewBuilderForCheckBoxNotRelevantMarksState
    extends State<ListViewBuilderForCheckBoxNotRelevantMarks> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.marks.length,
        itemBuilder: (ctx, index) {
          return Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.secondary,
                child: CheckboxListTile(
                    activeColor: Theme.of(context).canvasColor,
                    checkColor: Colors.white,
                    title: Text(
                      widget.marks.keys.toList()[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                    value: widget.isChecked[index],
                    onChanged: (bool? val) {
                      setState(() {
                        widget.isChecked[index] = val as bool;
                      });
                    }),
              ),
              const SizedBox(
                height: 5,
              )
            ],
          );
        },
      ),
    );
  }
}
