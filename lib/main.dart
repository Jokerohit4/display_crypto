import 'package:display_crypto/home_page.dart';
import 'package:display_crypto/services/bloc/crypto_bloc.dart';
import 'package:display_crypto/services/bloc/crypto_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => CryptoBloc()..add(FetchCryptoData()),
        child: MyHomePage(),
      ),
    );
  }
}



