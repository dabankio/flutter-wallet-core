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

class WalletCoreOptions {
  final bool beta;
  final bool shareAccountWithParentChain;
  const WalletCoreOptions({this.beta = false, this.shareAccountWithParentChain = false});
}

class WalletCore {

  static const _channel = MethodChannel('flutter_wallet_core');

  static Future<String> generateMnemonic() async {
    final mnemonic = await _channel.invokeMethod<String>('generateMnemonic');
    return mnemonic;
  }

  static Future<Map<String, Keys>> importMnemonic(
    bool useBip44,
    String mnemonic,
    String path,
    String password,
    List<String> symbols,
    [WalletCoreOptions options = const WalletCoreOptions()]
  ) async {
    final keyInfo = Map<String, dynamic>.from(
      await _channel.invokeMethod(
        'importMnemonic',
        {
          "useBip44": useBip44,
          "mnemonic": mnemonic,
          "path": path,
          "password": password,
          "symbols": symbols.join(","),
          "beta": options.beta,
          "shareAccountWithParentChain": options.shareAccountWithParentChain,
        },
      ),
    );

    return keyInfo.map(
      (key, value) => MapEntry(
        key,
        Keys(
          address: value["address"],
          publicKey: value["publicKey"],
        ),
      ),
    );
  }

  static Future<String> signTx(
    bool useBip44,
    String mnemonic,
    String path,
    String password,
    String symbol,
    String rawTx,
    [WalletCoreOptions options = const WalletCoreOptions()]
  ) async {
    final String signedTx = await _channel.invokeMethod<String>(
      "signTx",
      {
        "useBip44": useBip44,
        "mnemonic": mnemonic,
        "path": path,
        "password": password,
        "symbol": symbol,
        "rawTx": rawTx,
        "beta": options.beta,
        "shareAccountWithParentChain": options.shareAccountWithParentChain,
      },
    );
    return signedTx;
  }
}
