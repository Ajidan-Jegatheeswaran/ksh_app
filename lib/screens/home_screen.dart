import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {}, //TODO: Verlinkung zum ProfilScreen()
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {}, //Todo: Noten hinzufügen Screen oder Bottom Sheet 
          ),
        ],
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.add), onPressed: (){}, backgroundColor: Theme.of(context).canvasColor,),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
