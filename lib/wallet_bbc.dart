import 'dart:async';

import 'package:flutter/services.dart';


class BbcAddress {
  final String address;
  final String publicKey;
  final String privateKey;
  BbcAddress({this.address, this.publicKey, this.privateKey});
}

class WalletBbc {
  
  static const _channel = MethodChannel('flutter_wallet_core');

  static Future<BbcAddress> createFromMnemonic(
    String salt,
    String mnemonic,
  ) async {
    final keyInfo = Map<String, dynamic>.from(
      await _channel.invokeMethod(
        'bbcCreateFromMnemonic',
        {
          "salt": salt,
          "mnemonic": mnemonic,
        },
      ),
    );
    return BbcAddress(
      address: keyInfo["address"],
      publicKey: keyInfo["publicKey"],
      privateKey: keyInfo["privateKey"],
    );
  }

  static Future<BbcAddress> createFromPrivateKey(
    String privateKey,
  ) async {
    final keyInfo = Map<String, dynamic>.from(
      await _channel.invokeMethod(
        'bbcCreateFromPrivateKey',
        {
          "privateKey": privateKey,
        },
      ),
    );
    return BbcAddress(
      address: keyInfo["address"],
      publicKey: keyInfo["publicKey"],
      privateKey: keyInfo["privateKey"],
    );
  }

  static Future<String> signTxWithTemplate(
    String rawTx,
    String privateKey,
    String templateData,
  ) async {
    final result = await _channel.invokeMethod<String>(
      'bbcSignTxWithTemplate',
      {
        'rawTx': rawTx,
        "privateKey": privateKey,
        'templateData': templateData,
      },
    );
    return result;
  }
}
