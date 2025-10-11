import 'package:flutter/material.dart';
import 'package:hemaya/screens/login_screen.dart';
import 'package:hemaya/services/api_service.dart';
import 'package:hemaya/theme/app_theme.dart';
import 'package:hemaya/utils/constants.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email = '';
  String name = '';
  String password = '';
  String confirmPassword = '';
  bool isPasswordMatch = true;

  Future<bool> registerUser(String email, String password, String name) async {
    try {
      print("👤 Registering user: $email");

      final result = await ApiService.signUp(email, password, name);

      if (result['success'] == true) {
        print("✅ User registered successfully: $email");
        return true;
      } else {
        print("❌ Registration failed for user: $email - ${result['error']}");
        return false;
      }
    } catch (e) {
      print("❌ Registration error: $e");
      return false;
    }
  }

  Future<void> _handleRegistration() async {
    setState(() {
      isPasswordMatch = password == confirmPassword;
    });

    if (!isPasswordMatch) {
      return;
    }

    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى ملء جميع الحقول")));
      return;
    }

    final bool isRegistered = await registerUser(email, password, name);

    if (!mounted) return;

    if (isRegistered) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen(isLoggedIn: false)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("البريد الإلكتروني موجود بالفعل")));
    }
  }

  Widget _buildTextField({
    required String labelText,
    required IconData icon,
    required Function(String) onChanged,
    bool isPassword = false,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5.0),
      child: SizedBox(
        width: 250,
        height: 50,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: TextField(
            textDirection: TextDirection.rtl,
            textAlign: isPassword ? TextAlign.right : TextAlign.start,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.errorColor),
              ),
              filled: true,
              fillColor: AppTheme.cardColor,
              labelText: labelText,
              labelStyle: AppTheme.bodyTextStyle.copyWith(color: AppTheme.textSecondary),
              prefixIcon: Icon(icon, color: AppTheme.textSecondary),
              errorText: errorText,
              errorStyle: AppTheme.smallTextStyle.copyWith(color: AppTheme.errorColor),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: 250,
      height: 40,
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
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 10),
            child: Text(text, style: AppTheme.buttonTextStyle),
          ),
        ),
      ),
    );
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
                child: Image.asset(AppConstants.appLogo, width: 140, height: 140),
              ),
              Container(
                height: MediaQuery.of(context).size.height - 170,
                alignment: Alignment.bottomCenter,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                ),
                margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 20.0),
                padding: const EdgeInsets.only(top: 20, bottom: 80),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text("إنشاء حساب", style: AppTheme.titleTextStyle),
                    ),
                    _buildTextField(
                      labelText: 'إيميل المستخدم',
                      icon: Icons.email,
                      onChanged: (value) => setState(() => email = value),
                    ),
                    _buildTextField(
                      labelText: 'اسم المستخدم',
                      icon: Icons.person,
                      onChanged: (value) => setState(() => name = value),
                    ),
                    _buildTextField(
                      labelText: 'كلمة المرور',
                      icon: Icons.lock,
                      isPassword: true,
                      errorText: !isPasswordMatch ? 'كلمة المرور غير متطابقة' : null,
                      onChanged: (value) => setState(() => password = value),
                    ),
                    _buildTextField(
                      labelText: 'تأكيد كلمة المرور',
                      icon: Icons.lock,
                      isPassword: true,
                      errorText: !isPasswordMatch ? 'كلمة المرور غير متطابقة' : null,
                      onChanged: (value) => setState(() => confirmPassword = value),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: _buildGradientButton(text: "إنشاء حساب", onPressed: _handleRegistration),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 22.0),
                      child: _buildGradientButton(
                        text: 'تسجيل الدخول',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen(isLoggedIn: false)),
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
    );
  }
}
