import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

//Von dier Quelle ist diese Klasse inspiriert -> https://google.github.io/charts/flutter/example/combo_charts/date_time_line_point.html
class MarkChartWidget extends StatelessWidget {
  final List<String> dates;
  final List<double> marks;
  final List<charts.Series<DateTime, dynamic>> data = [];

  MarkChartWidget(this.dates, this.marks);

  getDates(List<String> dates) {
    List<DateTime> datesConverted = [];

    for (var i = 0; i < dates.length; i++) {
      List<String> fragmentDate = dates[i].split('.');
      DateTime date = DateTime(int.parse(fragmentDate[2]),
          int.parse(fragmentDate[1]), int.parse(fragmentDate[0]));
      datesConverted.add(date);
    }
    return datesConverted;
  }

  void _createChart() {
    //data.add(charts.Series(domainFn: (var marks, i) => marks, measureFn: getDates(dates)));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
