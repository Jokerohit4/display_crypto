

import 'dart:convert';

import 'package:display_crypto/services/bloc/crypto_state.dart';
import 'package:display_crypto/string_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  late io.Socket socket;

  CryptoBloc() : super(CryptoInitial()) {
    on<FetchCryptoData>(_onFetchCryptoData);
    on<UpdateCryptoData>(_onUpdateCryptoData);
  }

  void _onFetchCryptoData(FetchCryptoData event, Emitter<CryptoState> emit) {
    emit(CryptoLoaded([]));
  }

  void _onUpdateCryptoData(UpdateCryptoData event, Emitter<CryptoState> emit) {
    if (state is CryptoLoaded) {
      final currentState = state as CryptoLoaded;
      final updatedData = List<dynamic>.from(currentState.cryptoData);

      final index = updatedData.indexWhere((item) => item['token'] == event.newData['token']);
      if (index != -1) {
        if (updatedData[index] != event.newData) {
          updatedData[index] = event.newData;
          emit(CryptoLoaded(List.from(updatedData)));
        }
      } else {
        updatedData.add(event.newData);
        emit(CryptoLoaded(List.from(updatedData)));
      }
    }
  }


  Future<void> connectToSocket() async {
    const url = StringConstants.url;
    const token = StringConstants.token;
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("API Data: $data"); // Debugging: Check API response
      final tokens = (data['payload']['CRYPTO'] as List)
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
          debugPrint('Subscribed to $room');
          socket.on(room, (data) {
            try {
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
              add(UpdateCryptoData(decodedData));

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
  Future<void> close() {
    socket.dispose();
    return super.close();
  }
}
