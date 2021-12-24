import 'dart:convert';

import 'package:ksh_app/models/subject.dart';

class DuoMarkNew {
  final Subject sub1;
  final Subject sub2;

  DuoMarkNew({required this.sub1, required this.sub2});

  bool _isRelevant() {
    if (sub1.isNotRelevant || sub2.isNotRelevant) {
      return true;
    }
    return false;
  }

  double get mark => (sub1.mark + sub2.mark) / 2;

  static String toJson(DuoMarkNew duoMarkNew) => jsonEncode({
        'firstSubject': Subject.toJson(duoMarkNew.sub1),
        'secondSubject': Subject.toJson(duoMarkNew.sub2),
        'avarageMark': duoMarkNew.mark,
        'isRelevant': duoMarkNew._isRelevant()
      });

  static DuoMarkNew fromJson(String jsonString) {
    Map<String, dynamic> map = jsonDecode(jsonString);
    Subject firstSubject = Subject.fromJson(map['firstSubject']);
    Subject secondSubject = Subject.fromJson(map['secondSubject']);
    return DuoMarkNew(sub1: firstSubject, sub2: secondSubject);
  }
}
