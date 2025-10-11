import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hemaya/providers/call_state.dart';
import 'package:hemaya/screens/join_screen.dart';
import 'package:hemaya/screens/registeration_screen.dart';
import 'package:hemaya/services/api_service.dart';
import 'package:hemaya/services/local_auth_service.dart';
import 'package:hemaya/theme/app_theme.dart';
import 'package:hemaya/utils/constants.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../services/signalling.service.dart';

class LoginScreen extends StatefulWidget {
  final bool isLoggedIn;
  const LoginScreen({required this.isLoggedIn, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  String password = '';
  bool isButtonPressed = false;
  bool isLoading = false;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, double>> getCurrentPosition() async {
    final Location location = Location();

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

    // Get the current position using updated API
    final geo.Position position = await geo.Geolocator.getCurrentPosition(
      locationSettings: const geo.LocationSettings(accuracy: geo.LocationAccuracy.high, distanceFilter: 100),
    );

    return {'latitude': position.latitude, 'longitude': position.longitude};
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      print('🔑 Attempting login for email: $email');

      final result = await ApiService.signIn(email, password);

      if (result['success'] == true) {
        final userData = result['data'] as Map<String, dynamic>;
        print('✅ Login successful for user: ${userData["name"]}');
        return userData;
      } else {
        print('❌ Login failed: ${result['error']}');
        return null;
      }
    } catch (e) {
      print('❌ Login error: $e');
      return null;
    }
  }

  Future<void> _navigateToJoinScreen(Map<String, dynamic> user, double latitude, double longitude) async {
    if (!mounted) return;

    try {
      // init signalling service
      SignallingService.instance.init(websocketUrl: AppConstants.websocketUrl, selfCallerID: user["call_key"]);

      print('Setting up call listener...');
      SignallingService.instance.socket!.on("newMobileCall", (data) {
        print('Incoming call offer received');
        if (mounted) {
          final callState = Provider.of<CallState>(context, listen: false);
          callState.setIncomingCall(data);
          print('Call data: $data');
        }
      });

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JoinScreen(
              selfCallerId: user["id"],
              name: user["name"],
              email: user["email"],
              password: user["password"],
              lat: latitude,
              long: longitude,
              userId: user["id"],
            ),
          ),
        );
      }
    } catch (e) {
      print('Navigation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ في الاتصال')));
      }
    }
  }

  Future<void> _handleLogin() async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء جميع الحقول')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Map<String, dynamic>? user = await login(username, password);

      if (user != null && mounted) {
        final Map<String, double> position = await getCurrentPosition();
        final double? latitude = position["latitude"];
        final double? longitude = position["longitude"];

        // Store user data securely
        await storage.write(key: "userId", value: user["id"]);
        await storage.write(key: "email", value: user["email"]);
        await storage.write(key: "password", value: user["password"]);
        await storage.write(key: "name", value: user["name"]);
        await storage.write(key: "call_key", value: user["call_key"]);

        if (mounted) {
          await _navigateToJoinScreen(user, latitude ?? 0.0, longitude ?? 0.0);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("بيانات المستخدم غير صحيحة"), backgroundColor: Colors.red));
      }
    } catch (e) {
      print('Login process error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ في تسجيل الدخول')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() {
      isLoading = true;
    });

    try {
      final authentication = await LocalAuth.authenticate();
      print('Biometric authentication result: $authentication');

      if (authentication == true && mounted) {
        final userId = await storage.read(key: "userId");
        final name = await storage.read(key: "name");
        final email = await storage.read(key: "email");
        final password = await storage.read(key: "password");
        final callKey = await storage.read(key: "call_key");

        if (userId != null && name != null && email != null && password != null && callKey != null) {
          final Map<String, double> position = await getCurrentPosition();
          final double? latitude = position["latitude"];
          final double? longitude = position["longitude"];

          final Map<String, dynamic> user = {
            "id": userId,
            "name": name,
            "email": email,
            "password": password,
            "call_key": callKey,
          };

          if (mounted) {
            await _navigateToJoinScreen(user, latitude ?? 0.0, longitude ?? 0.0);
          }
        }
      }
    } catch (e) {
      print('Biometric login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل في المصادقة البيومترية')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required String labelText,
    required IconData icon,
    required bool isPassword,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10.0),
      child: SizedBox(
        width: 250,
        height: 50,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: TextField(
            textDirection: TextDirection.rtl,
            obscureText: isPassword,
            style: AppTheme.bodyTextStyle,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.cardColor,
              labelText: labelText,
              labelStyle: AppTheme.bodyTextStyle.copyWith(color: AppTheme.textSecondary),
              prefixIcon: Icon(icon, color: AppTheme.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback onPressed, double width = 250}) {
    return SizedBox(
      width: width,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.buttonGradient,
          borderRadius: AppTheme.buttonBorderRadius,
          boxShadow: AppTheme.buttonShadow,
        ),
        child: TextButton(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(AppTheme.textPrimary),
            backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: AppTheme.buttonBorderRadius),
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(text, style: AppTheme.buttonTextStyle),
        ),
      ),
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
                  child: Image.asset(AppConstants.appLogo, width: 140, height: 140),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 210,
                  alignment: Alignment.bottomCenter,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                  ),
                  margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 20.0),
                  padding: const EdgeInsets.only(top: 20, bottom: 50),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text("تسجيل الدخول", style: AppTheme.titleTextStyle),
                      ),
                      // Username field
                      Visibility(
                        visible: !widget.isLoggedIn || isButtonPressed,
                        child: _buildTextField(
                          labelText: 'إيميل المستخدم',
                          icon: Icons.person,
                          isPassword: false,
                          onChanged: (value) => setState(() => username = value),
                        ),
                      ),
                      // Password field
                      Visibility(
                        visible: !widget.isLoggedIn || isButtonPressed,
                        child: _buildTextField(
                          labelText: 'كلمة المرور',
                          icon: Icons.lock,
                          isPassword: true,
                          onChanged: (value) => setState(() => password = value),
                        ),
                      ),
                      // Login button
                      Visibility(
                        visible: !widget.isLoggedIn || isButtonPressed,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildGradientButton(text: 'دخول', onPressed: _handleLogin),
                        ),
                      ),
                      // Forgot password button
                      Visibility(
                        visible: !widget.isLoggedIn || isButtonPressed,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextButton(
                            style: ButtonStyle(
                              foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                              backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
                            ),
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                            child: const Text('نسيت كلمة المرور', style: TextStyle(fontSize: 17)),
                          ),
                        ),
                      ),
                      // Biometric login button
                      Visibility(
                        visible: widget.isLoggedIn && !isButtonPressed,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40.0, bottom: 40),
                          child: _buildGradientButton(text: 'دخول عبر بصمة الوجه', onPressed: _handleBiometricLogin),
                        ),
                      ),
                      // Switch login method button
                      Visibility(
                        visible: widget.isLoggedIn,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: _buildGradientButton(
                            text: 'تغيير وسيلة الدخول',
                            onPressed: () => setState(() => isButtonPressed = !isButtonPressed),
                          ),
                        ),
                      ),
                      // Register button
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: _buildGradientButton(
                          text: 'إنشاء حساب جديد',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                            );
                          },
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
