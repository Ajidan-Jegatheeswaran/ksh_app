import 'package:flutter/material.dart';

class NotenScreen extends StatelessWidget {
  final _markLength = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Noten'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(),
    );
  }
}
