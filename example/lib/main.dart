import 'package:flutter/material.dart';

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
  String privateKey;

  final String path = "m/44'/0'/0'/0/0";
  final String password = "test_core_wallet_ios";
  final List<String> symbols = ["BTC", "ETH", "USDT(Omni)"];

  @override
  void initState() {
    super.initState();
  }

  void generateMnemonic() async {
    final mnemonic = await WalletCore.generateMnemonic();
    setState(() {
      this.mnemonic = mnemonic;
    });
  }

  void importMnemonic(BuildContext context) async {
    final wallets =
        await WalletCore.importMnemonic(mnemonic, path, password, symbols, false);

    showBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(child: Column(
          children: wallets.keys
              .map(
                (symbol) => Container(
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.all(10),
                  color: Colors.grey.shade200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Text('\nAddress: ${wallets[symbol].address}'),
                      Text('\nPublicKey: ${wallets[symbol].publicKey}\n'),
                    ],
                  ),
                ),
              )
              .toList(),
        )) ,
      ),
    );
  }

  void bbcCreateFromMnemonic(BuildContext context) async {
    if (mnemonic.isNotEmpty) {
      final walletInfo = await WalletBbc.createFromMnemonic(password, mnemonic);
      privateKey = walletInfo.privateKey;
      showBottomSheet(
        context: context,
        builder: (_) => Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Text('Address:\n ${walletInfo.address}\n\n'),
              Text('PublicKey:\n ${walletInfo.publicKey}\n\n'),
              Text('PrivateKey:\n ${walletInfo.privateKey}\n\n'),
            ],
          ),
        ),
      );
    }
  }

  void bbcCreateFromPrivateKey(BuildContext context) async {
    if (privateKey.isNotEmpty) {
      final walletInfo = await WalletBbc.createFromPrivateKey(privateKey);
      showBottomSheet(
        context: context,
        builder: (_) => Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Text('bbcCreateFromPrivateKey:\n $privateKey\n\n'),
              Text('Address:\n ${walletInfo.address}\n\n'),
              Text('PublicKey:\n ${walletInfo.publicKey}\n\n'),
              Text('PrivateKey:\n ${walletInfo.privateKey}\n\n'),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter wallet core example app'),
        ),
        body: Builder(
          builder: (context) => SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Mnemonic:"),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                  child: Text(
                      mnemonic ?? 'First you need to create a new mnemonic'),
                ),
                 Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                  child: Text(
                      privateKey != null ? 'privateKey:$privateKey': ''),
                ),
                FlatButton(
                  color: Colors.blue[500],
                  child: Text(
                    "Generate Mnemonic",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: generateMnemonic,
                ),
                FlatButton(
                  color: Colors.blue[500],
                  child: Text(
                    "Import Mnemonic",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => importMnemonic(context),
                ),
                FlatButton(
                  color: Colors.blue[500],
                  child: Text(
                    "Create BBC Wallet from Mnemonic",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => bbcCreateFromMnemonic(context),
                ),

                 FlatButton(
                  color: Colors.blue[500],
                  child: Text(
                    "Create BBC Wallet from privateKey",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => bbcCreateFromPrivateKey(context),
                )
              ],
            ),
          )),
        ),
      ),
    );
  }
}
