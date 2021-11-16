import 'package:flutter/material.dart';

class DuoNoteErstellenSelectWidget extends StatelessWidget {
  final String text;

  DuoNoteErstellenSelectWidget(this.text);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        margin: const EdgeInsets.only(top: 15),
        color: Theme.of(context).colorScheme.secondary,
        height: 50,
        width: mediaQuery.width - 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Auswählen'),
            )
          ],
        ),
      ),
    );
  }
}
