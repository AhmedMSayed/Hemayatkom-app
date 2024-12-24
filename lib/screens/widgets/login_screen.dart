import 'package:flutter/material.dart';
import 'package:hemaya/screens/join_screen.dart';
import 'package:hemaya/screens/registeration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  String password = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 20.0),
                padding: const EdgeInsets.only(top: 20, bottom: 160),
                child: Column(
                  children: [
                    const Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        "تسجيل الدخول",
                        style: TextStyle(color: Colors.white, fontSize: 24.0),
                      ),
                    ),
                    Padding(
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
                    Padding(
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
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        height: 35,
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
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.transparent),
                            ),
                            onPressed: () async {
                              // ignore: use_build_context_synchronously
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 10.0, left: 10),
                              child: const Text(
                                  style: TextStyle(fontSize: 16), 'دخول'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(
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
                        child: const Text(
                            style: TextStyle(fontSize: 17), 'نسيت كلمة المرور'),
                      ),
                    ),
                    Padding(
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
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              backgroundColor: MaterialStateProperty.all<Color>(
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
                                  'دخول عبر بصمة الوجه'),
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
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              backgroundColor: MaterialStateProperty.all<Color>(
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
    );
  }
}
