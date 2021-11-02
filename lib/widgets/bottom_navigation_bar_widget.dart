import 'package:flutter/material.dart';
import 'package:ksh_app/screens/home_screen.dart';
import 'package:ksh_app/screens/noten_screen.dart';

class BottomNavigatioinBarWidget extends StatefulWidget {
  @override
  State<BottomNavigatioinBarWidget> createState() =>
      _BottomNavigatioinBarWidgetState();
}

class _BottomNavigatioinBarWidgetState
    extends State<BottomNavigatioinBarWidget> {
  final List<String> _pages = [
    HomeScreen.routeName,
    NotenScreen.routeName,
    //SettingsScreen.routeName //todo: SettingsScreen erstellen
  ];

  int _selectedPageIndex = 0;

  void _tabSelected(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: _tabSelected,
      
      backgroundColor: Theme.of(context).primaryColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.space_dashboard, color: Colors.white),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.school,
              color: Colors.white,
            ),
            label: 'Noten'),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings,
            color: Colors.white,
          ),
          label: 'Einstellungen',
        ),
      ],
    );
  }
}
