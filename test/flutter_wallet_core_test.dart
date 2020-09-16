import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_core/flutter_wallet_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('#generateMnemonic', () async {
    String mnemonic = await WalletCore.generateMnemonic();
    expect(mnemonic, isNotNull);
    expect(mnemonic.length, isNot(0));
  });

  group("#importMnemonic", () {
    final String password = "test_flutter_wallet_core";
    List<String> symbols = ["BTC", "ETH", "BBC", "USDT"];

    test("with default path", () async {
      final String mnemonic = await WalletCore.generateMnemonic();
      final String path = "m/44'/0'/0'/0/0";
      Map<String, Keys> keyInfo = await WalletCore.importMnemonic(
          mnemonic,
          path,
          password,
          symbols,
          WalletCoreOptions(beta: false, shareAccountWithParentChain: false));

      expect(keyInfo.keys.toList(), symbols);

      for (String symbol in keyInfo.keys) {
        final Keys keys = keyInfo[symbol];

        expect(keys.publicKey, isNotNull);
        expect(keys.address, isNotNull);
      }
    });

    test("with dabank legecy path", () async {
      final String mnemonic = await WalletCore.generateMnemonic();
      final String path = "m/44'/%d'";
      Map<String, Keys> keyInfo =
          await WalletCore.importMnemonic(mnemonic, path, password, symbols);

      expect(keyInfo.keys.toList(), symbols);

      for (String symbol in keyInfo.keys) {
        final Keys keys = keyInfo[symbol];

        expect(keys.publicKey, isNotNull);
        expect(keys.address, isNotNull);
      }
    });

    test("with custom path", () async {
      final String mnemonic = await WalletCore.generateMnemonic();
      final String path = "m/44'/0'/1'/0/0";
      Map<String, Keys> keyInfo =
          await WalletCore.importMnemonic(mnemonic, path, password, symbols);

      expect(keyInfo.keys.toList(), symbols);

      for (String symbol in keyInfo.keys) {
        final Keys keys = keyInfo[symbol];

        expect(keys.publicKey, isNotNull);
        expect(keys.address, isNotNull);
      }
    });
  });

  group("#signTx", () {
    final String password = "test_flutter_wallet_core";
    final String path = "m/44'/0'/0'/0/0";

    test("sign BTC tx", () async {
      final String symbol = "BTC";
      final String mnemonic = await WalletCore.generateMnemonic();
      final String rawTx = "test_tx";
      final String signTx = await WalletCore.signTx(mnemonic, path, password, symbol, rawTx);
      expect(signTx, isNotNull);
    });

    test("sign ETH tx", () async {
      final String symbol = "BTC";
      final String mnemonic = await WalletCore.generateMnemonic();
      final String rawTx = "test_tx";
      final String signTx =
          await WalletCore.signTx(mnemonic, path, password, symbol, rawTx);
      expect(signTx, isNotNull);
    });

    test("sign BBC tx", () async {
      final String symbol = "BTC";
      final String mnemonic = await WalletCore.generateMnemonic();
      final String rawTx = "test_tx";
      final String signTx = await WalletCore.signTx(mnemonic, path, password, symbol, rawTx);
      expect(signTx, isNotNull);
    });

    test("sign USDT tx", () async {
      final String symbol = "BTC";
      final String mnemonic = await WalletCore.generateMnemonic();
      final String rawTx = "test_tx";
      final String signTx =
          await WalletCore.signTx(mnemonic, path, password, symbol, rawTx);
      expect(signTx, isNotNull);
    });
  });
}
