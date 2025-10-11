import 'package:flutter/material.dart';
import 'package:hemaya/providers/call_state.dart';
import 'package:hemaya/screens/call_screen.dart';
import 'package:hemaya/utils/constants.dart';
import 'package:provider/provider.dart';

class IncomingCall extends StatefulWidget {
  final dynamic offer;
  final Function() onCallEnded;
  const IncomingCall({required this.offer, required this.onCallEnded, super.key});

  @override
  State<IncomingCall> createState() => _IncomingCallState();
}

class _IncomingCallState extends State<IncomingCall> with TickerProviderStateMixin {
  dynamic callOffer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    callOffer = widget.offer;

    // Initialize animation
    _animationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.repeat(reverse: true);

    if (mounted) {
      print("📞 IncomingCall Widget initialized for: ${callOffer['name'] ?? 'Unknown'}");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _acceptCall() async {
    if (!mounted) return;

    final callState = context.read<CallState>();
    callState.acceptCall();

    print('🚀 Accepting incoming call for userId: ${callOffer["callerId"]}');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callerId: callOffer["callerId"] ?? "",
          calleeId: callOffer["sdpOffer"]["call_key"] ?? "",
          offer: callOffer,
          lat: callOffer["lat"]?.toDouble() ?? 0.0,
          long: callOffer["long"]?.toDouble() ?? 0.0,
          name: callOffer["name"] ?? "Emergency Caller",
          userId: callOffer["callerId"] ?? "",
          isIncomingCall: true,
        ),
      ),
    );

    widget.onCallEnded();
  }

  void _rejectCall() {
    if (!mounted) return;

    final callState = context.read<CallState>();
    callState.clearIncomingCall();
  }

  @override
  Widget build(BuildContext context) {
    final callerName = callOffer['name'] ?? 'Emergency Caller';
    final hasLocation = callOffer['lat'] != null && callOffer['long'] != null;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(AppConstants.primaryColorValue), Color(AppConstants.secondaryColorValue)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Caller info
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مكالمة طوارئ واردة',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(callerName, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    if (hasLocation) ...[
                      const SizedBox(height: 4),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: Colors.white70, size: 16),
                          SizedBox(width: 4),
                          Text('موقع متاح', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reject button
              GestureDetector(
                onTap: _rejectCall,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.call_end, color: Colors.white, size: 30),
                ),
              ),
              // Accept button
              GestureDetector(
                onTap: _acceptCall,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.call, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
