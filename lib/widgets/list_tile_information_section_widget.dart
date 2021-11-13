import 'package:flutter/material.dart';

class ListTileInformationSectionWidget extends StatelessWidget {
  final String name;
  final String value;

  ListTileInformationSectionWidget(this.name, this.value);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Container(
      width: mediaQuery.width - 30 - 30,
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Column(
        
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.9,
            child: Text(
              name,
              style: TextStyle(color: Colors.white),
              textScaleFactor: 1.2,
              textAlign: TextAlign.start,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Opacity(
            opacity: 0.4,
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
              textScaleFactor: 1.1,
            ),
          ),
        ],
      ),
    );
    /*
    return ListTile(
      title: Text(
        name,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: Text(
        value,
        style: const TextStyle(color: Colors.white),
        
      ),
    );*/
  }
}
