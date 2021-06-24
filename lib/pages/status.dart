import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brands_names/services/socket_Service.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          socketService.socket.emit('emitir-mensaje', 'Hola desde flutter');
        },
      ),
      body: Center(
        child: Text('Server status: ${socketService.serverStatus}'),
      ),
    );
  }
}
