import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ksh_app/widgets/choose_school_widget.dart';
import '../models/user.dart';

class ChooseSchoolScreen extends StatelessWidget {
  static const routeName = '/choose-school';

  Map<String, String> subDomains = {
    'Kantonsschule Heerbrugg': 'ksh',
    'Kantonsschule am Burggraben': 'ksbg',
    'Kantonsschule Wil': 'kswil',
    'Kantonsschule Wattwil': 'ksw',
    'Kantonsschule am Brühl': 'ksb',
    'Kantonsschule Sargans': 'kss',

    //todo: Sobald es für die Kantonschulen funktioniert, kann es auf die Berufsschulen erweitert werden
    /*
    'Interstaatliche Maturitätsschule für Erwachsene': 'isme',
    'Berufs- und Weiterbildungszentrum Rorschach-Rheintal': 'brz',
    'Amt für Berufsbildung': 'zentrale',
    
    'Berufs- und Weiterbildungszentrum Buchs': 'bzb',
    'Berufs- und Weiterbildungszentrum Rapperswil-Jona': 'bwzr',
    'Berufs- und Weiterbildungszentrum für Gesundheits- und Sozialberufe':
        'bzgshf',
    'Berufs- und Weiterbildungszentrum Wil-Uzwil': 'bzwu',
    'Berufs- und Weiterbildungszentrum Toggenburg': 'bwzt',
    'Gewerbliches Berufs- und Weiterbildungszentrum St.Gallen': 'gbs',
    'Berufs- und Weiterbildungszentrum Wil-Zuwil Weiterbildung': 'bzwuwb',
    
    'Berufs- und Weiterbildungszentrum für Gesundheits- und Sozialberufe St.Gallen':
        'bzgs',
    'Berufs- und Weiterbildungszentrum Sarganserland': 'bzsl',
    */
  };

  late List<String> subDomainsName;
  late List<String> subDomainsSub;

  void main(List<String> args) async {}

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    var heightOfStatusBar = MediaQuery.of(context).padding.top;

    subDomainsName = subDomains.keys.toList();
    subDomainsSub = subDomains.values.toList();

    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: heightOfStatusBar,
              ),
              Container(
                child: const Center(
                  child: Text(
                    'Wähle deine Schule aus',
                    textScaleFactor: 1.4,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                height: mediaQuery.height * 0.1,
                width: mediaQuery.width,
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: subDomains.length,
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (BuildContext context, int index) {
                    return ChooseSchoolWidget(
                        subDomainsName[index], subDomainsSub[index]);
                  },
                ),
              ),
            ],
          ),
        )
        /*
        Column(
          children: [
            const Text(
              'Wähle deine Schule aus',
              style: TextStyle(color: Colors.white),
              textScaleFactor: 1.8,
            ),
            SizedBox(
              height: mediaQuery.height * 0.1,
            ),
            
          ],
        ))*/
        );
  }
}
