import 'package:flutter/material.dart';

class ListTileSettingWiget extends StatefulWidget {
  const ListTileSettingWiget({Key? key}) : super(key: key);
  

  @override
  _ListTileSettingWigetState createState() => _ListTileSettingWigetState();
}

class _ListTileSettingWigetState extends State<ListTileSettingWiget> {
  bool _isNotensaldoSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: SwitchListTile(
        activeTrackColor: Colors.white,
        activeColor: Colors.white,
        inactiveTrackColor: Theme.of(context).primaryColor,
        inactiveThumbColor: Theme.of(context).primaryColor,
        tileColor: Theme.of(context).colorScheme.secondary,
        onChanged: (bool value) {
          setState(() {
            _isNotensaldoSelected = value;
          });
        },
        value: _isNotensaldoSelected,
        title: const Text('Notensaldo', style: TextStyle(color: Colors.white)),
        
      ),
    );
  }
}
