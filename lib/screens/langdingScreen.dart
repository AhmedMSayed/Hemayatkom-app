import 'package:flutter/material.dart';

import 'package:hemaya/screens/login_screen.dart'; // Import the async library for Timer
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LandingScreen(),
    );
  }
}

class LandingScreen extends StatefulWidget {
  final storage = new FlutterSecureStorage();
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    // Start a timer to navigate to the next screen after a delay

    // Timer(Duration(seconds: 3), () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<dynamic>(
          future: LandingScreen().storage.read(key: "userId"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return LoginScreen(isLoggedIn: true);
            } else {
              // return Container(
              //   decoration: BoxDecoration(color: Colors.white),
              //   child: Center(
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Container(
              //           padding: const EdgeInsets.only(top: 10.0),
              //           child: Image.asset(
              //             'assets/hemaya.png',
              //             width: 170,
              //             height: 170,
              //           ),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.only(top: 40.0),
              //           child: Text(
              //             'ردع الجريمة قبل حدوثها',
              //             style: TextStyle(
              //               fontSize: 20,
              //               color: Colors.black87,
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // );
              return LoginScreen(isLoggedIn: false);
            }
          }),
    );
  }
}
