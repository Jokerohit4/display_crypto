import 'package:display_crypto/home_page.dart';
import 'package:display_crypto/socket_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => SocketDataProvider(),
        child: const MyHomePage(),
      ),
    );
  }
}

