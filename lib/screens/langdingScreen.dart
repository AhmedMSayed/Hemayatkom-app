import 'package:flutter/material.dart';

import 'package:hemaya/screens/login_screen.dart'; // Import the async library for Timer
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LandingScreen(),
    );
  }
}

class LandingScreen extends StatefulWidget {
  final storage = const FlutterSecureStorage();

  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
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
          future: const LandingScreen().storage.read(key: "userId"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const LoginScreen(isLoggedIn: true);
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
              return const LoginScreen(isLoggedIn: false);
            }
          }),
    );
  }
}
