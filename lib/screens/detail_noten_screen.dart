import 'package:flutter/material.dart';

class DetailNotenScreen extends StatelessWidget {
  static const routeName = '/detail-noten';
  late Map<String, dynamic> marksOfSubject;

  @override
  Widget build(BuildContext context) {
    var screenData = ModalRoute.of(context)!.settings.arguments! as Map;
    var mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(screenData['name']),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(right: 15, left: 15, top: 3, bottom: 15),
        child: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.secondary,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
              margin: EdgeInsets.only(bottom: mediaQuery.height * 0.013),
            ),
            const Text(
              'Deine Daten',
              style: TextStyle(color: Colors.white),
              textScaleFactor: 1.5,
            ),
            const SizedBox(
              height: 15,
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: marksOfSubject.length,
              itemBuilder: (ctx, index) {
                if (index == 0) {
                  return const SizedBox(
                    height: 0,
                    width: 0,
                  );
                }
                return Column(
                  children: const [
                    SizedBox(
                      height: 4,
                    )
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
