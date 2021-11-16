import 'dart:ffi';

import 'package:flutter/material.dart';

class NotRelevantMarksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> listOfNamesOfSubjects = [];
    //List<dynamic> listOfMaps = mapOfMarks.values.toList();
    for (var item in listOfNamesOfSubjects) {}

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Notensaldo - Nicht Relevant'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      //bottomNavigationBar: ,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
        backgroundColor: Colors.green
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (ctx, index) {
          return Container(
            margin: const EdgeInsets.only(top: 15, right: 15, left: 15),
            child: RadioListTile(
              title: const Text(
                'Mathematik',
                style: TextStyle(color: Colors.white),
              ),
              onChanged: (value) {
                print(value);
              },
              groupValue: 1,
              value: 1,
              tileColor: Theme.of(context).colorScheme.secondary,
              activeColor: Theme.of(context).canvasColor,
            ),
          );
        },
      ),
    );
  }
}
