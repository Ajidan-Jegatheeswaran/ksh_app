class Mark {
  final mark1;
  final mark2;

  Mark({this.mark1, this.mark2});

  //Rechnet den Durchschnit zwei Noten aus, welche jeweils eine Gewichtung haben z.B. eine Note zählt 40% und die andere 60%
  static double duoCount(double mark1, double mark2, int count1, int count2) {
    if (mark1 < 1 || mark2 < 1) {
      throw Exception();
    }
    if (count1 == 0 || count2 == 0) {
      throw Exception();
    }

    count1 = count1 ~/ 100;
    count2 = count2 ~/ 100;
    

    double zusammengerechnete = (mark1 * count1) + (mark2 * count2);
    return zusammengerechnete;
  }

  //Rechnet den Notenschnitt aus
  static double notenschnitt(Map<String, dynamic> map) {
    List list = map.values.toList();
    List<double> noten = [];
    double notenSumme = 0;

    for (var i in list) {
      noten.add(double.parse(i['Note']));
    }

    for(double i in noten){
      notenSumme += i;
    }

    double notenschnitt = notenSumme/noten.length;
    return notenschnitt;
  }
}
