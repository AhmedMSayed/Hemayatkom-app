import 'package:flutter/foundation.dart';

class CallState extends ChangeNotifier {
  bool _incomingCall = false;
  dynamic _sdpOffer;

  bool get incomingCall => _incomingCall;
  dynamic get sdpOffer => _sdpOffer;

  // Method to set incoming call data
  void setIncomingCall(dynamic data) {
    _incomingCall = true;
    _sdpOffer = data;
    notifyListeners(); // Notify listeners to update the UI
  }

  // Method to clear incoming call data
  void clearIncomingCall() {
    _incomingCall = false;
    _sdpOffer = null;
    notifyListeners(); // Notify listeners to update the UI
  }

  set incomingCall(bool value) {
    _incomingCall = value;
    notifyListeners();
  }

  set sdpOffer(dynamic value) {
    _sdpOffer = value;
    notifyListeners();
  }
}
