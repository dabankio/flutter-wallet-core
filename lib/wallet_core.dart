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
  final bool useBip44;
  const WalletCoreOptions(
      {this.beta = false,
      this.shareAccountWithParentChain = false,
      this.useBip44 = false});
}

class WalletCore {
  static const _channel = MethodChannel('flutter_wallet_core');

  static Future<String> generateMnemonic() async {
    final mnemonic = await _channel.invokeMethod<String>('generateMnemonic');
    return mnemonic;
  }

  static Future<Map<String, Keys>> importMnemonic(
      String mnemonic, String path, String password, List<String> symbols,
      [WalletCoreOptions options = const WalletCoreOptions()]) async {
    final keyInfo = Map<String, dynamic>.from(
      await _channel.invokeMethod(
        'importMnemonic',
        {
          "mnemonic": mnemonic,
          "path": path,
          "password": password,
          "symbols": symbols.join(","),
          "beta": options.beta,
          "shareAccountWithParentChain": options.shareAccountWithParentChain,
          "useBip44": options.useBip44,
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

  static Future<String> signTx(String mnemonic, String path, String password,
      String symbol, String rawTx,
      [WalletCoreOptions options = const WalletCoreOptions()]) async {
    final String signedTx = await _channel.invokeMethod<String>(
      "signTx",
      {
        "mnemonic": mnemonic,
        "path": path,
        "password": password,
        "symbol": symbol,
        "rawTx": rawTx,
        "beta": options.beta,
        "shareAccountWithParentChain": options.shareAccountWithParentChain,
        "useBip44": options.useBip44,
      },
    );
    return signedTx;
  }
}
