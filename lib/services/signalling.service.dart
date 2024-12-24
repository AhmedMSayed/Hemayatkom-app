import 'package:socket_io_client/socket_io_client.dart' as io;

class SignallingService {
  // instance of Socket
  io.Socket? socket;

  SignallingService._();

  static final instance = SignallingService._();

  init({required String websocketUrl, required String selfCallerID}) {
    // init Socket
    socket = io.io(
        websocketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setQuery({"callerId": selfCallerID})
            .disableAutoConnect()
            .build());

    // listen onConnect event
    socket!.onConnect((data) {
      print("Socket connected !!");
    });

    // listen onConnectError event
    socket!.onConnectError((data) {
      print("Socket not connected!! Error:: $data");
    });

    // connect socket
    socket!.connect();
  }
}
