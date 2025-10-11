import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hemaya/providers/call_state.dart';
import 'package:hemaya/utils/constants.dart';
import 'package:provider/provider.dart';
import '../services/signalling.service.dart';

class CallScreen extends StatefulWidget {
  final String callerId, calleeId, name, userId;
  final double? lat, long;
  final dynamic offer;
  final bool isIncomingCall;
  const CallScreen({
    required this.callerId,
    required this.calleeId,
    required this.name,
    required this.lat,
    required this.long,
    required this.userId,
    super.key,
    this.offer,
    this.isIncomingCall = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool incomingCall = false;
  // socket instance
  final socket = SignallingService.instance.socket;

  // videoRenderer for localPeer
  final _localRTCVideoRenderer = RTCVideoRenderer();

  // videoRenderer for remotePeer
  final _remoteRTCVideoRenderer = RTCVideoRenderer();

  // mediaStream for localPeer
  MediaStream? _localStream;

  // RTC peer connection
  RTCPeerConnection? _rtcPeerConnection;

  // list of rtcCandidates to be sent over signalling
  List<RTCIceCandidate> rtcIceCadidates = [];

  // media status
  bool isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true;
  int tapCount = 0;

  @override
  void initState() {
    incomingCall = widget.isIncomingCall;
    // initializing renderers
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();
    print("Incoming call status: $incomingCall");
    if (incomingCall) {
      _setupPeerConnection();
    }
    super.initState();
  }

  _setupPeerConnection() async {
    // create peer connection
    _rtcPeerConnection = await createPeerConnection({'iceServers': AppConstants.iceServers});

    // listen for remotePeer mediaTrack event
    _rtcPeerConnection!.onTrack = (event) {
      _remoteRTCVideoRenderer.srcObject = event.streams[0];
      setState(() {});
    };

    // get localStream
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': isAudioOn,
      'video': isVideoOn ? {'facingMode': isFrontCameraSelected ? 'user' : 'environment'} : false,
    });

    // add mediaTrack to peerConnection
    _localStream!.getTracks().forEach((track) {
      _rtcPeerConnection!.addTrack(track, _localStream!);
    });

    // set source for local video renderer
    _localRTCVideoRenderer.srcObject = _localStream;
    setState(() {});

    print("Peer connection setup completed for incoming call: $incomingCall");

    if (incomingCall) {
      // listen for Remote IceCandidate
      socket!.on("IceCandidate", (data) {
        final String candidate = data["iceCandidate"]["candidate"];
        final String sdpMid = data["iceCandidate"]["id"];
        final int sdpMLineIndex = data["iceCandidate"]["label"];

        // add iceCandidate
        _rtcPeerConnection!.addCandidate(RTCIceCandidate(candidate, sdpMid, sdpMLineIndex));
      });

      // set SDP offer as remoteDescription for peerConnection
      await _rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(widget.offer["sdpOffer"]["sdp"], widget.offer["sdpOffer"]["type"]),
      );

      // create SDP answer
      final RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();
      print("SDP Answer created successfully");
      print("Offer details: ${widget.offer["sdpOffer"]}");
      print("Answer: $answer");

      // set SDP answer as localDescription for peerConnection
      await _rtcPeerConnection!.setLocalDescription(answer);

      // send SDP answer to remote peer over signalling
      print("Sending answer from ${widget.callerId} to ${widget.calleeId}");

      socket!.emit("answerCall", {
        "callerId": widget.callerId,
        "calleeId": widget.calleeId,
        "sdpAnswer": answer.toMap(),
      });
    } else {
      _rtcPeerConnection!.onIceCandidate = (RTCIceCandidate candidate) => rtcIceCadidates.add(candidate);

      // when call is accepted by remote peer
      socket!.on("callAnswered", (data) async {
        print("Call answered - processing response");
        print("SDP Answer received: ${data["sdpAnswer"]}");

        // set SDP answer as remoteDescription for peerConnection
        await _rtcPeerConnection!.setRemoteDescription(
          RTCSessionDescription(data["sdpAnswer"]["sdp"], data["sdpAnswer"]["type"]),
        );

        // send iceCandidate generated to remote peer over signalling
        for (RTCIceCandidate candidate in rtcIceCadidates) {
          socket!.emit("IceCandidate", {
            "calleeId": widget.calleeId,
            "iceCandidate": {
              "id": candidate.sdpMid,
              "label": candidate.sdpMLineIndex,
              "candidate": candidate.candidate,
            },
          });
        }
      });

      // create SDP Offer
      final RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();

      // set SDP offer as localDescription for peerConnection
      await _rtcPeerConnection!.setLocalDescription(offer);

      // make a call to remote peer over signalling
      socket!.emit('makeCall', {
        "calleeId": widget.calleeId,
        "sdpOffer": offer.toMap(),
        "name": widget.name,
        "lat": widget.lat,
        "long": widget.long,
        "userId": widget.callerId,
      });
    }
  }

  _leaveCall() {
    Provider.of<CallState>(context, listen: false).clearIncomingCall();
    Navigator.pop(context);
  }

  _toggleMic() {
    // change status
    isAudioOn = !isAudioOn;
    // enable or disable audio track
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
    setState(() {});
  }

  _toggleCamera() {
    // change status
    isVideoOn = !isVideoOn;

    // enable or disable video track
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
    });
    setState(() {});
  }

  _switchCamera() {
    // change status
    isFrontCameraSelected = !isFrontCameraSelected;

    // switch camera
    _localStream?.getVideoTracks().forEach((track) {
      // ignore: deprecated_member_use
      track.switchCamera();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  RTCVideoView(
                    _localRTCVideoRenderer,
                    mirror: isFrontCameraSelected,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: SizedBox(
                      height: 150,
                      width: 120,
                      child: RTCVideoView(
                        _remoteRTCVideoRenderer,
                        mirror: isFrontCameraSelected,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                  if (!incomingCall)
                    Positioned(
                      bottom: 16.0, // Adjust the bottom position as needed
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // Handle the tap based on the tap count
                          if (tapCount == 0) {
                            // First tap - Make the call
                            _setupPeerConnection();
                            print('Making the call...');
                          } else if (tapCount == 1) {
                            // Second tap - Cancel the call
                            _leaveCall();
                            print('Canceling the call...');
                          }
                          // Increment the tap count
                          tapCount++;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red[700]),
                          padding: const EdgeInsets.all(32.0),
                          child: const Column(
                            children: [
                              Icon(Icons.call_end, color: Colors.white),
                              SizedBox(height: 8.0),
                              Text(
                                'Call',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: Icon(isAudioOn ? Icons.mic : Icons.mic_off), onPressed: _toggleMic),
                  if (incomingCall) IconButton(icon: const Icon(Icons.call_end), iconSize: 30, onPressed: _leaveCall),
                  IconButton(icon: const Icon(Icons.cameraswitch), onPressed: _switchCamera),
                  IconButton(icon: Icon(isVideoOn ? Icons.videocam : Icons.videocam_off), onPressed: _toggleCamera),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _localRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer.dispose();
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();
    super.dispose();
  }
}
