import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hemaya/providers/call_state.dart';
import 'package:hemaya/screens/join_screen.dart';
import 'package:hemaya/screens/langdingScreen.dart';
import 'package:hemaya/screens/registeration_screen.dart';
import 'package:hemaya/services/local_auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
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

  Future<Map<String, double>> getCurrentPosition() async {
    Location location = Location();

    bool isLocationServiceEnabled = await location.serviceEnabled();
    if (!isLocationServiceEnabled) {
      isLocationServiceEnabled = await location.requestService();
      if (!isLocationServiceEnabled) {
        print('Location services are disabled.');
        return {'latitude': 0.0, 'longitude': 0.0};
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('Location permission denied.');
        return {'latitude': 0.0, 'longitude': 0.0};
      }
    }

    // Get the current position (latitude and longitude)
    geo.Position position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );

    return {'latitude': position.latitude, 'longitude': position.longitude};
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

    final response = await http.post(url, body: reqBody, headers: headers);
    print("response :: $response");
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
    return PopScope(
      canPop: false,
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
                        padding: EdgeInsets.all(24.0),
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
                          child: SizedBox(
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
                                  prefixIcon: const Icon(Icons.person),
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
                                  prefixIcon: const Icon(Icons.lock),
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
                          child: SizedBox(
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
                                  boxShadow: const <BoxShadow>[
                                    BoxShadow(
                                        color: Color.fromRGBO(
                                            0, 0, 0, 0.57), //shadow for button
                                        blurRadius: 5) //blur radius of shadow
                                  ]),
                              child: TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.black),
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                onPressed: () async {
                                  Map<String, dynamic>? user =
                                      await login(username, password);

                                  if (user != null) {
                                    // ignore: use_build_context_synchronously
                                    Map<String, double> position =
                                        await getCurrentPosition();
                                    double? latitude = position["latitude"];
                                    double? longitude = position["longitude"];
                                    // ignore: use_build_context_synchronously

                                    const LandingScreen().storage.write(
                                        key: "userId", value: user["id"]);
                                    const LandingScreen().storage.write(
                                        key: "email", value: user["email"]);
                                    const LandingScreen().storage.write(
                                        key: "password",
                                        value: user["password"]);

                                    const LandingScreen().storage.write(
                                        key: "name", value: user["name"]);
                                    const LandingScreen().storage.write(
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
                                  padding:
                                      EdgeInsets.only(right: 10.0, left: 10),
                                  child: Text(
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
                              foregroundColor:
                                  WidgetStateProperty.all<Color>(Colors.white),
                              backgroundColor: WidgetStateProperty.all<Color>(
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
                          child: SizedBox(
                            width: 250,
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
                                  boxShadow: const <BoxShadow>[
                                    BoxShadow(
                                        color: Color.fromRGBO(
                                            0, 0, 0, 0.57), //shadow for button
                                        blurRadius: 5) //blur radius of shadow
                                  ]),
                              child: TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.black),
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                onPressed: () async {
                                  final authentication =
                                      await LocalAuth.authenticate();
                                  print("out");
                                  if (authentication == true) {
                                    const LandingScreen()
                                        .storage
                                        .read(key: "userId")
                                        .then((userId) {
                                      const LandingScreen()
                                          .storage
                                          .read(key: "name")
                                          .then((name) {
                                        const LandingScreen()
                                            .storage
                                            .read(key: "email")
                                            .then((email) {
                                          const LandingScreen()
                                              .storage
                                              .read(key: "password")
                                              .then((password) {
                                            const LandingScreen()
                                                .storage
                                                .read(key: "call_key")
                                                .then((callKey) async {
                                              Map<String, double> position =
                                                  await getCurrentPosition();
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
                                child: const Padding(
                                  padding: EdgeInsets.fromLTRB(8, 1, 8, 1),
                                  child: Text(
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
                          child: SizedBox(
                            width: 250,
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
                                  boxShadow: const <BoxShadow>[
                                    BoxShadow(
                                        color: Color.fromRGBO(
                                            0, 0, 0, 0.57), //shadow for button
                                        blurRadius: 5) //blur radius of shadow
                                  ]),
                              child: TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.black),
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                onPressed: () {
                                  // loginWithEmailAndPassword(username, password); temporarly disabled for testing

                                  setState(() {
                                    isButtonPressed = !isButtonPressed;
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.fromLTRB(8, 1, 8, 1),
                                  child: Text(
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
                        child: SizedBox(
                          width: 250,
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
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                      color: Color.fromRGBO(
                                          0, 0, 0, 0.57), //shadow for button
                                      blurRadius: 5) //blur radius of shadow
                                ]),
                            child: TextButton(
                              style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all<Color>(
                                    Colors.black),
                                backgroundColor: WidgetStateProperty.all<Color>(
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
                              child: const Padding(
                                padding: EdgeInsets.fromLTRB(8, 1, 8, 1),
                                child: Text(
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
