import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/widgets/bottom_navigation_bar_widget.dart';
import 'package:ksh_app/widgets/list_tile_setting_widget.dart';

class YourAccountScreen extends StatelessWidget {
  static const routeName = '/your-account';

  Future<Map<String,dynamic>> imagePathFuture = User.readFile(requiredFile.userImage);
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text('Dein Konto'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      bottomNavigationBar: BottomNavigatioinBarWidget(),
      body: FutureBuilder(
        future: imagePathFuture,
        builder: (BuildContext ctx, AsyncSnapshot<Object?> snap) {
          
          print('Snap Image');
          print(snap.data);
          Map<String, dynamic> _mapData = snap.data as Map<String, dynamic>;
          String _networkImagePath = _mapData['profilePicture'].toString();
          return ListView(
            padding: const EdgeInsets.all(15),
            children: [
              CircleAvatar(
                foregroundImage: NetworkImage(_networkImagePath),
              )
            ],
          );
        },
      ),
    );
  }
}
