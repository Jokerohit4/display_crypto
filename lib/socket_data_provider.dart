



import 'package:flutter/material.dart';

class SocketDataProvider with ChangeNotifier {
  final List<dynamic> _data = [];

  List<dynamic> get data => _data;

  void addData(dynamic jsonData) {
    _data.add(jsonData);
    notifyListeners();
  }
}
