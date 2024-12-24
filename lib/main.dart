import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hemaya/screens/langdingScreen.dart';
import 'package:hemaya/widgets/incoming_call.dart';
import 'package:hemaya/providers/call_state.dart';

void main() {
  // Start videoCall app
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CallState()),
      ],
      child: VideoCallApp(),
    ),
  );
}

class VideoCallApp extends StatelessWidget {
  VideoCallApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer<CallState>(
        builder: (context, callState, child) {
          return Stack(
            children: [
              LandingScreen(),
            ],
          );
        },
      ),
    );
  }
}
