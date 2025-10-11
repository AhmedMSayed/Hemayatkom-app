import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hemaya/providers/call_state.dart';
import 'package:hemaya/screens/login_screen.dart';
import 'package:hemaya/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  // Start videoCall app
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.dark),
  );

  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => CallState())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.themeData,
      home: Consumer<CallState>(
        builder: (context, callState, child) {
          return Scaffold(
            body: FutureBuilder<String?>(
              future: storage.read(key: "userId"),
              builder: (context, snapshot) => LoginScreen(isLoggedIn: snapshot.hasData),
            ),
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
