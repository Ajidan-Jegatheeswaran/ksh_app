import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/screens/home_screen.dart';

//Hier können alle nicht-relevanten Noten ausgewählt werden, damit der Notensaldo diese nicht zählt
class NotRelevantMarksScreen extends StatefulWidget {
  static const routeName = '/not-relevant-marks';

  @override
  State<NotRelevantMarksScreen> createState() => _NotRelevantMarksScreenState();
}

class _NotRelevantMarksScreenState extends State<NotRelevantMarksScreen> {
  var _selectedSubjectForSubmit;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> mapOfSubjects = {};
    int _value = 0;
    Map<String, dynamic> marks = {};
    List<bool> isChecked = [];
    List<String> titles = [];
    Map<String, dynamic> settings = {};

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Notensaldo - Nicht relevante Noten'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic> newMap = {};

          for (int i = 0; i < marks.length; i++) {
            Map<String, dynamic> map = marks.values.toList()[i];
            map['relevant'] = isChecked[i];
            newMap[marks.keys.toList()[i]] = map;
          }
          for (var i = 0; i < titles.length; i++) {
            settings[titles[i]] = isChecked[i];
          }
          print(settings);
          await User.writeInToFile(newMap, requiredFile.userMarks);
          await User.writeInToFile(settings, requiredFile.userNotRelevantMarks);
          print('New Map Not Relevant Marks');
          print(newMap);
          await User.syncNotRelevantMarks();
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
        future: User.readFile(requiredFile.userMarks),
        builder: (ctx, snap) {
          switch (snap.connectionState) {
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());

            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
          }

          marks = snap.data as Map<String, dynamic>;
          for (var i = 0; i < marks.length; i++) {
            titles.add('');
          }
          isChecked = List<bool>.filled(marks.length, false);
          print('Marks Not Relevant');
          print(marks);

          return SingleChildScrollView(
            child: Column(
              children: [
                ListViewBuilderForCheckBoxNotRelevantMarks(
                    marks: marks, isChecked: isChecked, titles: titles),
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
                      widget.marks.values.toList()[index]['Fach'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    value: widget.isChecked[index],
                    onChanged: (bool? val) {
                      setState(() {
                        print('Val bool print');
                        print(val as bool);
                        widget.isChecked[index] = val;
                        widget.titles[index] =
                            widget.marks.values.toList()[index]['Fach'];
                        print('Checked');
                        print(widget.isChecked[index]);
                        print('title');
                        print(widget.titles[index]);
                      });

                      if (widget.isChecked[index]) {
                        print('Printing Printing');
                      }
                    }),
              ),
              SizedBox(
                height: 5,
              )
            ],
          );
        },
      ),
    );
  }
}
