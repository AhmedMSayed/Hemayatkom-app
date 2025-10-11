import 'package:flutter/foundation.dart';

class AppConstants {
  // Network Configuration
  // Get my computer localhost ip from ipconfig getifaddr en0
  static String get websocketUrl => kDebugMode ? "https://192.168.1.8:443" : "https://hemayatkom.site:443";
  static String get baseUrl => kDebugMode ? "https://192.168.1.8" : "https://hemayatkom.site";

  static const String signInEndpoint = '/signin';
  static const String signUpEndpoint = '/users';
  static const String usersEndpoint = '/users';
  static const String sessionsEndpoint = '/session';
  static const String validateCallEndpoint = '/validateMobileCall';
  static const String sessionCloseEndpoint = '/session/closed';
  static const String sessionOpenEndpoint = '/session/open';
  static const String deleteLatestSessionEndpoint = '/session/latest';

  // Asset paths
  static const String appLogo = 'assets/hemaya.png';
  static const String completeIcon = 'assets/complete.png';
  static const String holdIcon = 'assets/hold.png';
  static const String logoutIcon = 'assets/logout.png';
  static const String newDocIcon = 'assets/newdoc.png';
  static const String profileIcon = 'assets/profile.png';
  static const String messagesIcon = 'assets/messages.png';
  static const String userIcon = 'assets/user.png';

  // Colors
  static const int primaryColorValue = 0xFF009F98;
  static const int secondaryColorValue = 0xFF1281AE;

  // WebRTC Configuration
  static const List<Map<String, dynamic>> iceServers = [
    {
      'urls': ['stun:stun1.l.google.com:19302', 'stun:stun2.l.google.com:19302'],
    },
  ];
}
