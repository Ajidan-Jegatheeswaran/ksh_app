import 'package:flutter/material.dart';

class ListTileInformationSectionWidget extends StatelessWidget {

  final String name;
  final String value;

  ListTileInformationSectionWidget(this.name, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        name,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: Text(
        value,
        style: const TextStyle(color: Colors.white),
        textScaleFactor: 1.4,
      ),
    );
  }
}
