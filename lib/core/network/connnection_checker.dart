import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class ConnnectionChecker {
  Future<bool> get isConnected;
}

class ConnnectionCheckerImpl implements ConnnectionChecker {
  final InternetConnection internetConnection;

  ConnnectionCheckerImpl(this.internetConnection);
  @override
  Future<bool> get isConnected async {
    return await internetConnection.hasInternetAccess;
  }
}
