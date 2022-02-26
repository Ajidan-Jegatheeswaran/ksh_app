//Ist ein Model für ein Fach
import 'dart:convert';

import 'test.dart';

class Subject {
  final String title;
  final String name;
  final double mark;
  final bool isNotRelevant;
  List<Test>? singleMarks;

  Subject(
      {required this.title,
      required this.name,
      required this.mark,
      this.isNotRelevant = false,
      this.singleMarks});

  add(Test test) {
    if (singleMarks!.isEmpty) {
      singleMarks = [];
    }
    singleMarks!.add(test);
    
  }

  static void toJson(Subject sub) => jsonEncode({
        'title': sub.title,
        'name': sub.name,
        'mark': sub.mark,
        'isNotRelevant': sub.isNotRelevant
      });

  static Subject fromJson(String jsonString) {
    Map<String, dynamic> map = jsonDecode(jsonString);
    return Subject(
        title: map['title'],
        name: map['name'],
        mark: map['mark'],
        isNotRelevant: map['isNotRelevant']);
  }
  String markAsString(){
    if(mark == 0.0){
      return '--';
    }else{
      return mark.toString();
    }
  }
}
