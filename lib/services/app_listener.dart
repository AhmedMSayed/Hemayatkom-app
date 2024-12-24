import 'package:flutter/material.dart';
import '../services/signalling.service.dart';
import 'dart:math';

class AppListener extends StatefulWidget {
  final Widget child;

  const AppListener({Key? key, required this.child}) : super(key: key);

  @override
  _AppListenerState createState() => _AppListenerState();
}

class _AppListenerState extends State<AppListener> {
  dynamic incomingSDPOffer;
  // signalling server url
  final String websocketUrl = "http://13.36.63.83:5000";

  // generate callerID of local user
  final String selfCallerID =
      Random().nextInt(999999).toString().padLeft(6, '0');

  // @override
  // void initState() {
  //   super.initState();

  //   // init signalling service
  //   SignallingService.instance.init(
  //     websocketUrl: websocketUrl,
  //     selfCallerID: selfCallerID,
  //   );

  //   print('# ' * 100);
  //   SignallingService.instance.socket!.on("newMobileCall", (data) {
  //     print("CALL OFFER:");
  //     print(data["callerID"]);
  //     // set SDP Offer of incoming call
  //     setState(() {
  //       incomingSDPOffer = data;
  //     });
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
