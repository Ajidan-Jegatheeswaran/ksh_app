import 'package:flutter/material.dart';

class ListTileSettingWiget extends StatefulWidget {
  final String title;

  ListTileSettingWiget(this.title);
  

  @override
  _ListTileSettingWigetState createState() => _ListTileSettingWigetState();
}

class _ListTileSettingWigetState extends State<ListTileSettingWiget> {
  bool _isNotensaldoSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      color: Theme.of(context).primaryColor,
      child: SwitchListTile(
        activeTrackColor: Colors.white,
        activeColor: Colors.white,
        inactiveTrackColor: Theme.of(context).colorScheme.secondary,
        inactiveThumbColor: Theme.of(context).colorScheme.secondary,
        tileColor: Theme.of(context).colorScheme.secondary,
        onChanged: (bool value) {
          setState(() {
            _isNotensaldoSelected = value;
          });
        },
        value: _isNotensaldoSelected,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        
      ),
    );
  }
}
