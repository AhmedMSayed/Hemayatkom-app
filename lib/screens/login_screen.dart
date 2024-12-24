import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hemaya/providers/call_state.dart';
import 'package:hemaya/screens/join_screen.dart';
import 'package:hemaya/screens/langdingScreen.dart';
import 'package:hemaya/screens/registeration_screen.dart';
import 'package:hemaya/services/local_auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';
// import 'package:hemaya/providers/user_provider.dart';
import '../services/signalling.service.dart';

class LoginScreen extends StatefulWidget {
  final bool isLoggedIn;
  const LoginScreen({super.key, required this.isLoggedIn});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  String password = '';
  static bool isButtonPressed = false;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, double>> getLocation() async {
    try {
      // Request permission to access the device's location
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // Handle the case when the user denies the location permission
        print('Location permission denied.');
        return {'latitude': 0.0, 'longitude': 0.0};
      }

      if (permission == LocationPermission.deniedForever) {
        // Handle the case when the user denies the location permission forever
        print(
            'Location permission denied forever. You need to enable it from settings.');
        return {'latitude': 0.0, 'longitude': 0.0};
      }

      // Get the current position (latitude and longitude)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high, // You can choose the desired accuracy
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      print('Latitude: $latitude, Longitude: $longitude');
      return {'latitude': latitude, 'longitude': longitude};
    } catch (e) {
      print('Error getting location: $e');
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }

  Future<void> requestLocationPermission() async {
    // Check if the location permission is already granted
    if (await Permission.location.isGranted) {
      print('Location permission already granted.');
      return;
    }

    // Request the location permission
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      print('Location permission granted.');
    } else if (status.isDenied) {
      print('Location permission denied.');
    } else if (status.isPermanentlyDenied) {
      print(
          'Location permission permanently denied. You need to enable it from settings.');
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse("https://hemaya.site/signin");

    print(email);
    print(password);

    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    var data = {'email': email, 'password': password};

    var reqBody = jsonEncode(data);

    print(reqBody);

    final response = await http.post(url, body: reqBody, headers: headers);
    print(response.body);
    if (response.statusCode == 200) {
      // If user found, return the response body as a Map
      final Map<String, dynamic> userData = json.decode(response.body);
      // Provider.of<UserProvider>(context, listen: false)
      //     .setUserCallKey(userData["call_key"]);
      return userData;
    } else {
      // If no user found or other error, return null
      return null;
    }
  }

  _navigateToJoinScreen(user, latitude, longitude) {
    // signalling server url
    const String websocketUrl = "https://hemaya.site:443";

    // init signalling service
    SignallingService.instance.init(
      websocketUrl: websocketUrl,
      selfCallerID: user["call_key"],
    );

    print('# ' * 100);
    SignallingService.instance.socket!.on("newMobileCall", (data) {
      print("CALL OFFER:");
      // Access the CallState provider
      final callState = Provider.of<CallState>(context, listen: false);
      // Set SDP Offer of incoming call
      callState.setIncomingCall(data);
      print(data);
      print('# ' * 100);
    });

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => JoinScreen(
              selfCallerId: user["id"],
              name: user["name"],
              email: user["email"],
              password: user["password"],
              lat: latitude,
              long: longitude,
              userId: user["id"])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Image.asset(
                    'assets/hemaya.png',
                    width: 140,
                    height: 140,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 210,
                  alignment: Alignment.bottomCenter,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF009F98), Color(0xFF1281AE)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  margin:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 20.0),
                  padding: const EdgeInsets.only(top: 20, bottom: 50),
                  child: Column(
                    children: [
                      const Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          "تسجيل الدخول",
                          style: TextStyle(color: Colors.white, fontSize: 24.0),
                        ),
                      ),
                      Visibility(
                        visible: !widget.isLoggedIn ^ isButtonPressed,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Container(
                            width: 250,
                            height: 50,
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: TextField(
                                textDirection: TextDirection.rtl,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'إيميل المستخدم',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    username = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !widget.isLoggedIn ^ isButtonPressed,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Container(
                            width: 250,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  10), // Adjust the radius as needed
                              color: Colors.white,
                            ),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: TextField(
                                textDirection: TextDirection.rtl,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'كلمة المرور',
                                  prefixIcon: Icon(Icons.lock),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    password = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !widget.isLoggedIn ^ isButtonPressed,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            height: 40,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(207, 207, 207, 207),
                                      Colors.white,
                                      //add more colors
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Color.fromRGBO(
                                            0, 0, 0, 0.57), //shadow for button
                                        blurRadius: 5) //blur radius of shadow
                                  ]),
                              child: TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                onPressed: () async {
                                  Map<String, dynamic>? user =
                                      await login(username, password);

                                  if (user != null) {
                                    // ignore: use_build_context_synchronously
                                    await requestLocationPermission();
                                    Map<String, double> position =
                                        await getLocation();
                                    double? latitude = position["latitude"];
                                    double? longitude = position["longitude"];
                                    // ignore: use_build_context_synchronously

                                    LandingScreen().storage.write(
                                        key: "userId", value: user["id"]);
                                    LandingScreen().storage.write(
                                        key: "email", value: user["email"]);
                                    LandingScreen().storage.write(
                                        key: "password",
                                        value: user["password"]);

                                    LandingScreen().storage.write(
                                        key: "name", value: user["name"]);
                                    LandingScreen().storage.write(
                                        key: "call_key",
                                        value: user["call_key"]);
                                    _navigateToJoinScreen(
                                        user, latitude, longitude);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text("Invalid user")));
                                  }
                                  // ignore: use_build_context_synchronously
                                },
                                child: const Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10.0, left: 10),
                                  child: const Text(
                                      style: TextStyle(fontSize: 16), 'دخول'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !widget.isLoggedIn ^ isButtonPressed,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.transparent),
                            ),
                            onPressed: () async {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) =>
                              //           const RegistrationScreen()),
                              // );
                            },
                            child: const Text(
                                style: TextStyle(fontSize: 17),
                                'نسيت كلمة المرور'),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.isLoggedIn ^ isButtonPressed,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40.0, bottom: 40),
                          child: Container(
                            width: 250,
                            height: 40,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(207, 207, 207, 207),
                                      Colors.white,
                                      //add more colors
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Color.fromRGBO(
                                            0, 0, 0, 0.57), //shadow for button
                                        blurRadius: 5) //blur radius of shadow
                                  ]),
                              child: TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                onPressed: () async {
                                  final authentication =
                                      await LocalAuth.authenticate();
                                  print("out");
                                  if (authentication == true) {
                                    LandingScreen()
                                        .storage
                                        .read(key: "userId")
                                        .then((userId) {
                                      LandingScreen()
                                          .storage
                                          .read(key: "name")
                                          .then((name) {
                                        LandingScreen()
                                            .storage
                                            .read(key: "email")
                                            .then((email) {
                                          LandingScreen()
                                              .storage
                                              .read(key: "password")
                                              .then((password) {
                                            LandingScreen()
                                                .storage
                                                .read(key: "call_key")
                                                .then((callKey) async {
                                              await requestLocationPermission();
                                              Map<String, double> position =
                                                  await getLocation();
                                              double? latitude =
                                                  position["latitude"];
                                              double? longitude =
                                                  position["longitude"];

                                              Map<String, dynamic> user = {
                                                "id": userId!,
                                                "name": name!,
                                                "email": email!,
                                                "password": password!,
                                                "lat": latitude!,
                                                "long": longitude!,
                                                "userId": userId,
                                                "call_key": callKey,
                                              };

                                              _navigateToJoinScreen(
                                                  user, latitude, longitude);
                                            });
                                          });
                                        });
                                      });
                                    });
                                  }
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                  child: const Text(
                                      style: TextStyle(fontSize: 16),
                                      'دخول عبر بصمة الوجه'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.isLoggedIn,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Container(
                            width: 250,
                            height: 40,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(207, 207, 207, 207),
                                      Colors.white,
                                      //add more colors
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Color.fromRGBO(
                                            0, 0, 0, 0.57), //shadow for button
                                        blurRadius: 5) //blur radius of shadow
                                  ]),
                              child: TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                onPressed: () {
                                  // loginWithEmailAndPassword(username, password); temporarly disabled for testing

                                  setState(() {
                                    isButtonPressed = !isButtonPressed;
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                  child: const Text(
                                      style: TextStyle(fontSize: 16),
                                      'تغيير وسيلة الدخول'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          width: 250,
                          height: 40,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(207, 207, 207, 207),
                                    Colors.white,
                                    //add more colors
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(7),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Color.fromRGBO(
                                          0, 0, 0, 0.57), //shadow for button
                                      blurRadius: 5) //blur radius of shadow
                                ]),
                            child: TextButton(
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
                              ),
                              onPressed: () {
                                // loginWithEmailAndPassword(username, password); temporarly disabled for testing
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationScreen()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                child: const Text(
                                    style: TextStyle(fontSize: 16),
                                    'إنشاء حساب جدبد'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
