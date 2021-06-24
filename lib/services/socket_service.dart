import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

enum ServerStatus {
  Online,
  Offline,
  Connecting,
}

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  SocketService() {
    this._initConfig();
  }
  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  _initConfig() {
    this._socket = IO.io(
        'https://flutter-bands-cronda.herokuapp.com/',
        IO.OptionBuilder()
            .enableAutoConnect()
            .setTransports(['websocket']).build());

    this._socket.onConnect((_) {
      print('connect');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    this._socket.onConnectError((_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    this._socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    // this._socket.on('active-bands', (payload) {
    //   print('nuevo-mensaje: $payload');
    // });
  }
}
