import 'package:flutter/material.dart';

class ChooseSchoolWidget extends StatelessWidget {
  final String schoolName;
  final String imgPath;

  ChooseSchoolWidget(this.schoolName, this.imgPath);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Center(child: Text(schoolName)),

    );
  }
}
