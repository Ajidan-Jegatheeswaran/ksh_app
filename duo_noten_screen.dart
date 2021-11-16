import 'package:flutter/material.dart';
import 'package:not_relevant_screen/widgets/duo_note_erstellen_select_widget.dart';

class DuoNotenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Duo Note erstellen'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15),
        child: Column(
          
          children: [
            Container(
              //todo: Farbe für Container einstellen und ListTile Farben zu primary machen
              width: mediaQuery.width - 30,
              child: const Center(
                
                child: Text(
                  'Fächer auswählen',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            DuoNoteErstellenSelectWidget('Wähle Fach Nr. 1'),
            DuoNoteErstellenSelectWidget('Wähle Fach Nr. 2')
          ],
        ),
      ),
    );
  }
}
