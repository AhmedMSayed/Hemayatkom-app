import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  final String name, userId, email, password;
  const Profile({
    super.key,
    required this.name,
    required this.userId,
    required this.email,
    required this.password,
  });

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
    phoneController.text =
        ""; // Add logic to retrieve phone number if available
    passwordController.text = widget.password;
  }

  void _saveChanges() {
    updateUser(
      context,
      widget.userId,
      nameController.text,
      emailController.text,
      phoneController.text,
      passwordController.text,
    );
    // .then((value) => {
    //       setState(() {
    //         isEditing = false;
    //       })
    //     })
    // .catchError((e) => print('Error: $e'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب المستخدم'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF009F98), Color(0xFF1281AE)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField("أسم المستخدم", nameController),
              _buildTextField("البريد الإلكترونى", emailController),
              _buildTextField("رقم الهاتف", phoneController),
              _buildTextField("كلمة المرور", passwordController,
                  isPassword: true),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: 500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 50.0, // Adjust the height to your desired size
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextButton(
                        onPressed: isEditing ? _saveChanges : null,
                        style: TextButton.styleFrom(
                            backgroundColor: isEditing
                                ? const Color(0xFF009F98)
                                : Colors.grey),
                        child: const Row(
                          children: [
                            Text(
                              'حفظ التغييرات',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            SizedBox(width: 8.0),
                            Icon(
                              Icons.save,
                              color: Colors.white,
                              size: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Container(
                      height: 50.0, // Adjust the height to your desired size
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF009F98), Color(0xFF1281AE)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
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
                            Text(
                              'تعديل',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            SizedBox(width: 8.0),
                            Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
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

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: isPassword
                          ? IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
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

Future<Map<String, dynamic>?> updateUser(BuildContext context, String userId,
    String name, String email, String phoneNumber, String password) async {
  final url = Uri.parse("https://hemaya.site/users/$userId");

  // Create a map with the updated user data
  Map<String, dynamic> userData = {
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'password': password,
  };

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      // User updated successfully
      // Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      // return jsonResponse;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      return null;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update user. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      // Request failed
      print('Failed to update user. Status code: ${response.statusCode}');
      return null;
    }
  } catch (error) {
    // Handle other errors, e.g., network issues
    print('Error: $error');
    return null;
  }
}
