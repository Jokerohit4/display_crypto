


abstract class CryptoState {}

class CryptoInitial extends CryptoState {}

class CryptoLoaded extends CryptoState {
  final List<dynamic> cryptoData;
  CryptoLoaded(this.cryptoData);
}

class CryptoError extends CryptoState {
  final String message;
  CryptoError(this.message);
}

// crypto_event.dart
abstract class CryptoEvent {}

class FetchCryptoData extends CryptoEvent {}

class UpdateCryptoData extends CryptoEvent {
  final Map<dynamic, dynamic> newData;
  UpdateCryptoData(this.newData);
}
