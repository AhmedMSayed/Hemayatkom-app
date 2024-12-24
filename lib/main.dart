import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hemaya/screens/langdingScreen.dart';
import 'package:hemaya/providers/call_state.dart';

void main() {
  // Start videoCall app
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
  ));

  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CallState()),
      ],
      child: const VideoCallApp(),
    ),
  );
}

class VideoCallApp extends StatelessWidget {
  const VideoCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer<CallState>(
        builder: (context, callState, child) {
          return const Stack(
            children: [
              LandingScreen(),
            ],
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
