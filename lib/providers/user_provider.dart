import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userCallKey = "";

  String get userCallKey => _userCallKey;

  void setUserCallKey(String callKey) {
    _userCallKey = callKey;
    notifyListeners();
  }
}
final userCallKeyProvider = Provider<String>(
  create: (context) {
    // You can initialize the call_key as needed
    return ""; // Initial value, you might want to use null or some default value
  },
);
