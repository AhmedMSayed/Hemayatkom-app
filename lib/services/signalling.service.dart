import 'package:socket_io_client/socket_io_client.dart' as io;

class SignallingService {
  // instance of Socket
  io.Socket? socket;
  String? _currentCallerId;

  SignallingService._();

  static final instance = SignallingService._();

  init({required String websocketUrl, required String selfCallerID}) {
    _currentCallerId = selfCallerID;

    // init Socket
    socket = io.io(
      websocketUrl,
      io.OptionBuilder().setTransports(['websocket']).setQuery({"callerId": selfCallerID}).disableAutoConnect().build(),
    );

    // listen onConnect event
    socket!.onConnect((data) {
      print("📞 Socket connected successfully for user: $selfCallerID");
    });

    // listen onConnectError event
    socket!.onConnectError((data) {
      print("❌ Socket connection failed: $data");
    });

    // listen onDisconnect event
    socket!.onDisconnect((data) {
      print("📞 Socket disconnected: $data");
    });

    // listen onError event
    socket!.onError((data) {
      print("❌ Socket error: $data");
    });

    // connect socket
    socket!.connect();
  }

  void disconnect() {
    if (socket != null) {
      print("📞 Disconnecting socket for user: $_currentCallerId");
      socket!.disconnect();
      socket!.dispose();
      socket = null;
      _currentCallerId = null;
    }
  }

  // Emit events with error handling
  void emit(String event, dynamic data) {
    if (socket != null) {
      socket!.emit(event, data);
    } else {
      print("❌ Socket not connected. Cannot emit event: $event");
    }
  }
}
