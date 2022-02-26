import 'dart:convert';

class Test {
  final String testName;
  final double mark;
  final DateTime date;
  final String? subjectName;
  final String? subjectTitle;

  Test(
      {required this.testName,
      required this.mark,
      required this.date,
      this.subjectName,
      this.subjectTitle}) {
        if(subjectName == Null && subjectTitle == Null){
          throw Exception('Fehler: Subject Name und Titel wurde bei der Erstellung eines Tests');
        }else if(subjectName == Null){
          
        }
      }

  static void toJson(Test test) => jsonEncode({
        'name': test.testName,
        'mark': test.mark,
        'date': test.date,
        'subjectName': test.subjectName,
        'subjectTitle': test.subjectTitle
      });

  static Test fromJson(String jsonString) {
    Map<String, dynamic> map = jsonDecode(jsonString);
    return Test(
        testName: map['name'],
        mark: map['mark'],
        date: map['date'],
        subjectName: map['subjectName'],
        subjectTitle: map['subjectTitle']);
  }
}
