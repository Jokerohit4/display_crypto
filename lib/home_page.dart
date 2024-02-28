import 'package:display_crypto/services/bloc/crypto_bloc.dart';
import 'package:display_crypto/services/bloc/crypto_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late CryptoBloc cryptoBloc;

  @override
  void initState() {
    super.initState();
    cryptoBloc = BlocProvider.of<CryptoBloc>(context);
    cryptoBloc.connectToSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Data with BLoC'),
      ),
      body: BlocBuilder<CryptoBloc, CryptoState>(
        builder: (context, state) {

          if (state is CryptoLoaded) {
            return ListView.builder(
              itemCount: state.cryptoData.length,
              itemBuilder: (context, index) {

                final item = state.cryptoData[index];
                return ListTile(
                  title: Text(item['instrument_identifier'] ?? 'Unknown'),
                  subtitle: Text('LTP: ${item['ltp'] ?? 'N/A'}'),
                  trailing: Text(item['price_change']),
                );
              },
            );
          } else if (state is CryptoError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  void dispose() {
    cryptoBloc.close();
    super.dispose();
  }
}
