import 'dart:io';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/band.dart';
import 'package:brands_names/services/socket_Service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActivBands);
    super.initState();
  }

  _handleActivBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: (socketService.serverStatus == ServerStatus.Offline)
                ? Icon(
                    Icons.offline_bolt,
                    color: Colors.red,
                  )
                : Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  ),
          )
        ],
        title: Text(
          "Bands Names",
          style: TextStyle(
            color: Colors.grey.shade700,
          ),
        ),
      ),
      body: bands.length > 0
          ? Column(
              children: [
                _showGraph(),
                Container(
                  child: Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: bands.length,
                      itemBuilder: (context, index) => _bandTile(bands[index]),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Text("Cargando...."),
            ),
      floatingActionButton: (bands.length < 7 && bands.length > 0)
          ? FloatingActionButton(
              elevation: 2,
              child: Icon(Icons.add),
              onPressed: addNewBand,
            )
          : null,
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) =>
          socketService.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.only(left: 8),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete band',
              style: TextStyle(color: Colors.white),
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue.shade100,
        ),
        title: Text(band.name),
        trailing: Text(
          band.votes.toString(),
          style: TextStyle(fontSize: 19),
        ),
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textEditController = new TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('New band name:'),
                content: TextField(
                  controller: textEditController,
                ),
                elevation: 1,
                actions: [
                  MaterialButton(
                    child: Text('Add'),
                    onPressed: () => addBandToList(textEditController.text),
                    textColor: Colors.blue,
                  )
                ],
              ));
    }

    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text('New band name:'),
              content: CupertinoTextField(
                controller: textEditController,
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Add'),
                  onPressed: () => addBandToList(textEditController.text),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text('Close'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      socketService.socket.emit("add-band", {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    final colorList = [
      Colors.amber,
      Colors.blue,
      Colors.lightGreen,
      Colors.teal,
      Colors.amberAccent,
      Colors.indigoAccent,
    ];
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartRadius: MediaQuery.of(context).size.width / 3,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.left,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: false,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: false,
            decimalPlaces: 0,
          ),
        ),
      ),
      width: double.infinity,
      height: 200,
    );
  }
}
