import 'package:flutter/material.dart';
import 'package:ksh_app/models/user.dart';
import 'package:ksh_app/screens/login_screen.dart';

class ChooseSchoolWidget extends StatelessWidget {
  final String schoolName;
  final String sub;

  ChooseSchoolWidget(this.schoolName, this.sub);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    void buttonMethod() async{
      Map<String,dynamic> _userData= {'subdomain':sub, 'schoolName':schoolName};
      User.writeInToFile(_userData, requiredFile.userHost);
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }

    return Card(
      elevation: 10,
      
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          TextButton(
            child: Container(
              //padding: EdgeInsets.symmetric(horizontal: 50),
              child: Center(child: Text(schoolName, textScaleFactor: 1.4, textWidthBasis: TextWidthBasis.longestLine,)),
              width: mediaQuery.width - 30,
              height: mediaQuery.height * 0.15,
            ),
            onPressed: buttonMethod,
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.secondary),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                textStyle: MaterialStateProperty.all(
                  const TextStyle(color: Colors.white,),
                )),
          ),
        ],
      ),
    );
  }
}
