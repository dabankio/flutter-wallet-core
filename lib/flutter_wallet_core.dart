import 'dart:async';

import 'package:flutter/services.dart';

class FlutterWalletCore {
  static const MethodChannel _channel =
      const MethodChannel('flutter_wallet_core');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
