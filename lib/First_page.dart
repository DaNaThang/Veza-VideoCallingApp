import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'LoginSignUpWidget.dart';
import 'SignUp.dart';
import 'LoginPage.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with SingleTickerProviderStateMixin {

  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    animation = Tween<double>(begin: 10, end: 40).animate(controller)
    ..addListener(() {
      setState(() {

      });
    });

    controller.forward();

  }

  @override
  void dipose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 70.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.center,
                height: 90.0,
                child: Image.asset('images/Veza.png'),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: Text(
                  'VEZA',
                  style: TextStyle(
                    letterSpacing: 10.0,
                    fontSize: 50.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 70.0),
                child: Text(
                  'Easy and fun way to connect',
                  style: TextStyle(
                    fontSize: 13.0,
                    letterSpacing: 1.0,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              LoginSignUp(
                  top: 50.0,
                  text: 'Sign In',
                  onpressed: Login,
                  color: Colors.deepOrangeAccent,
                  textcolor: Colors.white,
              ),
              LoginSignUp(
                  top: 30.0,
                  text: 'Sign Up',
                  onpressed: SignUp,
                  color: Colors.blueAccent,
                  textcolor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> Login() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage(),
      ),
    );
  }

  Future<void> SignUp() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage(),
      ),
    );
  }
}
