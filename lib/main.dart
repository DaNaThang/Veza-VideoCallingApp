// @dart=2.9

import 'package:flutter/material.dart';
import 'First_page.dart';
import 'Selection_Screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Join_meeting_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(VEZA());
}

class VEZA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        primaryColor: Color(0xFF1C86E8),
        scaffoldBackgroundColor: Color(0xFF161616),
      ),
      routes: {
        'First_page': (context) => FirstPage(),
      },
      initialRoute: 'First_page',
    );
  }
}