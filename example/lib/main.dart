import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_wallet_core/flutter_wallet_core.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String mnemonic;

  @override
  void initState() {
    super.initState();
  }

  void generateMnemonic() async {
    final String mnemonic = await WalletCore.generateMnemonic();

    setState(() {
      this.mnemonic = mnemonic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter wallet core example app'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FlatButton(
                    child: Text("Generate Mnemonic"),
                    onPressed: generateMnemonic)
              ],
            ),
          )),
    );
  }
}
