


import 'dart:convert';

import 'package:display_crypto/socket_data_provider.dart';
import 'package:display_crypto/string_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    fetchDataAndConnectSocket();
  }

  void fetchDataAndConnectSocket() async {
    var provider = Provider.of<SocketDataProvider>(context, listen: false);
    const url = StringConstants.url;
    const token = StringConstants.token;
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("API Data: $data"); // Debugging: Check API response
      final tokens = (data['payload']['NFO'] as List)
          .map((e) => e['token'].toString())
          .toList();


      socket = io.io('https://ws2.tradeyarr.com', io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build());
      socket.onConnect((_) {
        debugPrint('Socket Connected');
        for (var token in tokens) {
          final room = "room$token";
          socket.emit('tokenData', token);
          socket.emitWithAck('tokenData', token, ack: (data) {
            debugPrint('Acknowledgement received: $data');
          });
          debugPrint('Subscribed to $room');
          socket.on(room, (data) {
            try {
              // Check if data is already a decoded JSON object (Map)
              Map<dynamic, dynamic> decodedData;
              if (data is Map) {
                decodedData = data;
              } else if (data is String) {
                decodedData = json.decode(data);
              } else {
                debugPrint('Warning: Data received for $room is neither a Map nor a String: $data');
                return;
              }

              debugPrint('Data for $room: $decodedData');

              // Assuming addData expects a Map<String, dynamic>
              provider.addData(decodedData);
            } catch (e) {
              debugPrint('Error processing data for $room: $e');
            }
          });
        }
      });
      socket.connect();
    } else {
      debugPrint("Failed to fetch data from the API");
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SocketDataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket.IO Data'),
      ),
      body: ListView.builder(
        itemCount: provider.data.length,
        itemBuilder: (context, index) {
          final item = provider.data[index];
          return ListTile(
            title: Text(item['instrument_identifier'] ?? 'Unknown'),
            subtitle: Text('LTP: ${item['ltp'] ?? 'N/A'}'),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
}

