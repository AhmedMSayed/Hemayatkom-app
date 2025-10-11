import 'package:flutter/foundation.dart';

enum CallStatus { idle, incoming, ongoing, ended, connecting, reconnecting }

class CallState extends ChangeNotifier {
  bool _incomingCall = false;
  dynamic _sdpOffer;
  CallStatus _callStatus = CallStatus.idle;
  String? _callerId;
  String? _callerName;
  DateTime? _callStartTime;
  String? _errorMessage;
  bool _isConnected = false;
  double? _latitude;
  double? _longitude;

  // Getters
  bool get incomingCall => _incomingCall;
  dynamic get sdpOffer => _sdpOffer;
  CallStatus get callStatus => _callStatus;
  String? get callerId => _callerId;
  String? get callerName => _callerName;
  DateTime? get callStartTime => _callStartTime;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _isConnected;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  // Duration calculation
  Duration? get callDuration {
    if (_callStartTime != null && _callStatus == CallStatus.ongoing) {
      return DateTime.now().difference(_callStartTime!);
    }
    return null;
  }

  // Method to set incoming call data
  void setIncomingCall(dynamic data) {
    try {
      _incomingCall = true;
      _sdpOffer = data;
      _callStatus = CallStatus.incoming;
      _callerId = data['callerId']?.toString();
      _callerName = data['name']?.toString();
      _latitude = data['lat']?.toDouble();
      _longitude = data['long']?.toDouble();
      _errorMessage = null;

      print('📞 Incoming call from: $_callerName ($_callerId)');
      notifyListeners();
    } catch (e) {
      print('❌ Error setting incoming call: $e');
      _errorMessage = 'خطأ في استقبال المكالمة';
      notifyListeners();
    }
  }

  // Method to accept call
  void acceptCall() {
    if (_callStatus == CallStatus.incoming) {
      _callStatus = CallStatus.connecting;
      _callStartTime = DateTime.now();
      _incomingCall = false;
      _errorMessage = null;
      print('✅ Call accepted from: $_callerName');
      notifyListeners();
    }
  }

  // Method to clear incoming call data
  void clearIncomingCall() {
    _incomingCall = false;
    _sdpOffer = null;
    _callStatus = CallStatus.idle;
    _callerId = null;
    _callerName = null;
    _callStartTime = null;
    _errorMessage = null;
    _isConnected = false;
    _latitude = null;
    _longitude = null;
    print('📞 Call cleared');
    notifyListeners();
  }

  // Legacy setters for backward compatibility
  set incomingCall(bool value) {
    _incomingCall = value;
    if (!value) {
      clearIncomingCall();
    }
    notifyListeners();
  }

  set sdpOffer(dynamic value) {
    _sdpOffer = value;
    notifyListeners();
  }
}
