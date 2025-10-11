import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hemaya/providers/call_state.dart';
import 'package:hemaya/screens/login_screen.dart';
import 'package:hemaya/screens/messages.dart';
import 'package:hemaya/screens/profile.dart';
import 'package:hemaya/services/api_service.dart';
import 'package:hemaya/services/signalling.service.dart';
import 'package:hemaya/theme/app_theme.dart';
import 'package:hemaya/utils/constants.dart';
import 'package:hemaya/widgets/incoming_call.dart';
import 'package:provider/provider.dart';

import 'call_screen.dart';

class JoinScreen extends StatefulWidget {
  final String selfCallerId, name, userId, email, password;
  final double? lat;
  final double? long;

  const JoinScreen({
    required this.selfCallerId,
    required this.name,
    required this.email,
    required this.password,
    required this.lat,
    required this.long,
    required this.userId,
    super.key,
  });

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  dynamic incomingSDPOffer;
  final remoteCallerIdTextEditingController = TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleLogout() async {
    try {
      // Disconnect signalling service
      SignallingService.instance.disconnect();

      // Clear storage
      await storage.deleteAll();

      if (mounted) {
        // Navigate to login screen
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen(isLoggedIn: false)),
          (route) => false,
        );
      }
    } catch (e) {
      print('❌ Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء تسجيل الخروج'), backgroundColor: Colors.red));
      }
    }
  }

  // join Call
  _joinCall({
    required String callerId,
    required String calleeId,
    required String name,
    required double? lat,
    required double? long,
    required String? userId,
    dynamic offer,
  }) async {
    print('🚀 Starting call with userId: $userId');
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callerId: callerId,
          calleeId: calleeId,
          offer: offer,
          lat: lat,
          long: long,
          name: name,
          userId: userId!,
        ),
      ),
    );

    print('📞 Call ended');
    await _showSessionDialog();
  }

  Future<void> _showSessionDialog() async {
    try {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // User must tap a button
        builder: (BuildContext context) {
          print('🔥 Dialog builder called');
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Row(
                children: [
                  Icon(Icons.save, color: AppTheme.primaryColor, size: 24),
                  SizedBox(width: 8),
                  Text('حفظ الجلسة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text('هل تريد الاحتفاظ بهذه الجلسة في سجل البلاغات؟', style: TextStyle(fontSize: 16)),
              actions: <Widget>[
                TextButton(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('لا، احذف الجلسة', style: TextStyle(color: Colors.red, fontSize: 14)),
                  ),
                  onPressed: () async {
                    print('🗑️ Delete button pressed');
                    Navigator.of(context).pop(); // Close dialog
                    await _deleteSession();
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('نعم، احتفظ بالجلسة', style: TextStyle(color: Colors.white, fontSize: 14)),
                  onPressed: () {
                    print('✅ Keep button pressed');
                    Navigator.of(context).pop(); // Close dialog
                    // Do nothing - session is already saved
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('❌ Error showing dialog: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _deleteSession() async {
    try {
      // Show deleting indicator
      if (mounted) {
        unawaited(
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 16),
                  Text('جارٍ حذف الجلسة...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      }

      final result = await ApiService.deleteLatestSession(widget.selfCallerId);

      // Close deleting indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الجلسة بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'فشل في حذف الجلسة'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Close deleting indicator if still showing
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء حذف الجلسة'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      print('❌ Error deleting session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          color: AppTheme.backgroundColor,
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Image.asset(AppConstants.appLogo, width: 90, height: 90),
                      ),
                      Container(
                        margin: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Text(widget.name, style: const TextStyle(color: Colors.black45, fontSize: 18)),
                            Container(
                              margin: const EdgeInsets.only(right: 5, left: 5),
                              width: 45,
                              height: 45,
                              child: Image.asset(AppConstants.profileIcon),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.menu, color: Color.fromRGBO(10, 144, 163, 1)),
                              onSelected: (String value) async {
                                if (value == 'logout') {
                                  await _handleLogout();
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'logout',
                                  child: Row(
                                    children: [
                                      Icon(Icons.logout, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('تسجيل الخروج'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                      ),
                      margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 50),
                      child: Container(
                        margin: const EdgeInsets.only(top: 100),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            //بلاغ جديد
                            Container(
                              width: 250,
                              height: 50,
                              margin: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  _joinCall(
                                    callerId: widget.selfCallerId,
                                    calleeId: "1234",
                                    name: widget.name,
                                    lat: widget.lat,
                                    long: widget.long,
                                    userId: widget.selfCallerId,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Opacity(opacity: 0, child: Icon(Icons.arrow_forward)),
                                    const Text('بلاغ جديد', style: TextStyle(color: Colors.black)),
                                    SizedBox(height: 30, width: 30, child: Image.asset(AppConstants.newDocIcon)),
                                  ],
                                ),
                              ),
                            ),
                            //'البلاغات المغلقة'
                            Container(
                              width: 250,
                              height: 50,
                              margin: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Messages(userId: widget.selfCallerId, isAnsweredFilter: true),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Opacity(opacity: 0, child: Icon(Icons.arrow_forward)),
                                    const Text('البلاغات المغلقة', style: TextStyle(color: Colors.black)),
                                    SizedBox(height: 30, width: 30, child: Image.asset(AppConstants.completeIcon)),
                                  ],
                                ),
                              ),
                            ),
                            //'البلاغات المعلقة'
                            Container(
                              width: 250,
                              height: 50,
                              margin: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Messages(userId: widget.selfCallerId, isAnsweredFilter: false),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Opacity(opacity: 0, child: Icon(Icons.arrow_forward)),
                                    const Text('البلاغات المعلقة', style: TextStyle(color: Colors.black)),
                                    SizedBox(height: 30, width: 30, child: Image.asset(AppConstants.holdIcon)),
                                  ],
                                ),
                              ),
                            ),
                            //'صندوق الرسائل'
                            Container(
                              width: 250,
                              height: 50,
                              margin: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Messages(userId: widget.selfCallerId)),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Opacity(opacity: 0, child: Icon(Icons.arrow_forward)),
                                    const Text('صندوق الرسائل', style: TextStyle(color: Colors.black)),
                                    SizedBox(height: 30, width: 30, child: Image.asset(AppConstants.messagesIcon)),
                                  ],
                                ),
                              ),
                            ),
                            //حساب المستخدم
                            Container(
                              width: 250,
                              height: 50,
                              margin: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Profile(
                                        name: widget.name,
                                        userId: widget.userId,
                                        email: widget.email,
                                        password: widget.password,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Opacity(opacity: 0, child: Icon(Icons.arrow_forward)),
                                    const Text('حساب المستخدم', style: TextStyle(color: Colors.black)),
                                    SizedBox(height: 25, width: 25, child: Image.asset(AppConstants.userIcon)),
                                  ],
                                ),
                              ),
                            ),
                            //'تسجيل الخروج'
                            Container(
                              width: 250,
                              height: 50,
                              margin: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  elevation: 0,
                                ),
                                onPressed: () => _handleLogout(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Opacity(opacity: 0, child: Icon(Icons.arrow_forward)),
                                    const Text('تسجيل الخروج', style: TextStyle(color: Colors.black)),
                                    SizedBox(height: 30, width: 30, child: Image.asset(AppConstants.logoutIcon)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Consumer<CallState>(
                builder: (context, callState, child) {
                  print('Call state SDP offer: ${callState.sdpOffer}');
                  if (callState.incomingCall == false) {
                    // Handle the case where callState is null
                    return const SizedBox.shrink();
                  }
                  return Visibility(
                    visible: callState.incomingCall,
                    child: Positioned(
                      bottom: 200,
                      right: 90,
                      left: 90,
                      child: IncomingCall(
                        offer: callState.sdpOffer,
                        onCallEnded: () async {
                          print('🔥 Incoming call ended');
                          await _showSessionDialog();
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
