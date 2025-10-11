import 'package:flutter/material.dart';
import 'package:hemaya/services/api_service.dart';
import 'package:hemaya/theme/app_theme.dart';

class Profile extends StatefulWidget {
  final String name, userId, email, password;
  const Profile({required this.name, required this.userId, required this.email, required this.password, super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Controller for text fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isEditing = false;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Set the initial values of the text controllers
    nameController.text = widget.name;
    emailController.text = widget.email;
    phoneController.text = ""; // Add logic to retrieve phone number if available
    passwordController.text = widget.password;
  }

  void _saveChanges() async {
    if (!mounted) return;

    try {
      final userData = {
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
        'password': passwordController.text,
      };

      final result = await ApiService.updateUser(widget.userId, userData);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم تحديث البيانات بنجاح'), backgroundColor: Colors.green));
        setState(() {
          isEditing = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'فشل في تحديث البيانات'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('حدث خطأ في تحديث البيانات'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب المستخدم'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppTheme.primaryGradient)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField("أسم المستخدم", nameController),
              _buildTextField("البريد الإلكترونى", emailController),
              _buildTextField("رقم الهاتف", phoneController),
              _buildTextField("كلمة المرور", passwordController, isPassword: true),
              const SizedBox(height: 30),
              SizedBox(
                width: 500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 50.0,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
                      child: TextButton(
                        onPressed: isEditing ? _saveChanges : null,
                        style: TextButton.styleFrom(backgroundColor: isEditing ? AppTheme.primaryColor : Colors.grey),
                        child: const Row(
                          children: [
                            Text('حفظ التغييرات', style: TextStyle(color: Colors.white, fontSize: 20)),
                            SizedBox(width: 8.0),
                            Icon(Icons.save, color: Colors.white, size: 25),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      height: 50.0,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isEditing = !isEditing;
                          });
                        },
                        child: const Row(
                          children: [
                            Text('تعديل', style: TextStyle(color: Colors.white, fontSize: 20)),
                            SizedBox(width: 8.0),
                            Icon(Icons.edit, color: Colors.white, size: 20),
                          ],
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    controller: controller,
                    obscureText: isPassword && !isPasswordVisible,
                    readOnly: !isEditing,
                    enabled: isEditing,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      labelText: label,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: isPassword
                          ? IconButton(
                              icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                // Toggle the visibility state on button press
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
