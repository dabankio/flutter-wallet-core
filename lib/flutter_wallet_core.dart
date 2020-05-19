import 'dart:async';

import 'package:flutter/services.dart';

class WalletCoreSymbol {
  static final all = [btc, eth, bbc, usdt];
  static final btc = "BTC";
  static final eth = "ETH";
  static final bbc = "BBC";
  static final usdt = "USDT(Omni)";
}

class Keys {
  final String publicKey;
  final String address;

  Keys({this.publicKey, this.address});
}

class WalletCore {
  static const MethodChannel _channel =
      const MethodChannel('flutter_wallet_core');

  static Future<String> generateMnemonic() async {
    final String mnemonic =
        await _channel.invokeMethod<String>('generateMnemonic');
    return mnemonic;
  }

  static Future<Map<String, Keys>> importMnemonic(String mnemonic, String path,
      String password, List<String> symbols) async {
    print("$mnemonic, $path, $password, $symbols");

    final Map<String, dynamic> keyInfo = Map<String, dynamic>.from(
        await _channel.invokeMethod('importMnemonic', {
      "mnemonic": mnemonic,
      "path": path,
      "password": password,
      "symbols": symbols.join(",")
    }));

    print(keyInfo);

    return keyInfo.map((key, value) => MapEntry(
        key, Keys(address: value["address"], publicKey: value["publicKey"])));
  }

  static Future<String> signTx(String mnemonic, String path, String password,
      String symbol, String rawTx) async {
    final String signedTx = await _channel.invokeMethod<String>("signTx", {
      "mnemonic": mnemonic,
      "path": path,
      "password": password,
      "symbol": symbol,
      "rawTx": rawTx,
    });

    return signedTx;
  }
}
