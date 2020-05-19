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
  String mnemonic = "";
  Map<String, Keys> keys = {};

  final String path = "m/44'/0'/0'/0/0";
  final String password = "test_core_wallet_ios";
  final List<String> symbols = ["ETH", "USDT(Omni)"];

  @override
  void initState() {
    super.initState();
  }

  void generateMnemonic() async {
    final String mnemonic = await WalletCore.generateMnemonic();
    print(mnemonic);

    setState(() {
      this.mnemonic = mnemonic;
    });
  }

  void importMnemonic() async {
    final Map<String, Keys> keys =
        await WalletCore.importMnemonic(mnemonic, path, password, symbols);

    setState(() {
      this.keys = keys;
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
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("mnemonic:"),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                child: Text(mnemonic),
              ),
              FlatButton(
                  color: Colors.blue[500],
                  child: Text(
                    "Generate Mnemonic",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: generateMnemonic),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                      children: keys.keys.toList().map((symbol) {
                    return Container(
                        child: Column(
                      children: <Widget>[
                        Text(symbol),
                        Text("publicKey"),
                        Text(keys[symbol].publicKey),
                        Text("address"),
                        Text(keys[symbol].address),
                      ],
                    ));
                  }).toList())),
              FlatButton(
                  color: Colors.blue[500],
                  child: Text(
                    "Import Mnemonic",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: importMnemonic)
            ]),
      )),
    ));
  }
}
