class Test {
  final String testName;
  final double mark;
  final DateTime date;

  Test({required this.testName, required this.mark, required this.date});

  static DateTime createDate(int day, int month, int year) =>
      DateTime(year, month, day);

}
