import 'package:flutter/material.dart';
import 'package:ksh_app/screens/home_screen.dart';
import 'package:ksh_app/screens/my_account_screen.dart';
import 'package:ksh_app/screens/noten_screen.dart';


class BottomNavigatioinBarWidget extends StatefulWidget {
  @override
  State<BottomNavigatioinBarWidget> createState() =>
      _BottomNavigatioinBarWidgetState();
}

class _BottomNavigatioinBarWidgetState
    extends State<BottomNavigatioinBarWidget> {
  void _tabSelected(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).popAndPushNamed(HomeScreen.routeName);
        break;
      case 1:
        Navigator.of(context).popAndPushNamed(NotenScreen.routeName);
        break;
      case 2:
        Navigator.of(context).popAndPushNamed(MyAccountScreen.routeName);
    }
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
            Icons.person,
            color: Colors.white,
          ),
          label: 'Dein Konto',
        ),
      ],
    );
  }
}
