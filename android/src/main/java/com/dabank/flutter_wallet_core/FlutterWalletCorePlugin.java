package com.dabank.flutter_wallet_core;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import Wallet.WalletBuilder;
import Wallet.Wallet;

/** FlutterWalletCorePlugin */
public class FlutterWalletCorePlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_wallet_core");
    channel.setMethodCallHandler(new FlutterWalletCorePlugin());
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_wallet_core");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("generateMnemonic")) {
      String mnemonic = this.generateMnemonic();
      result.success(mnemonic);
    } else if (call.method.equals("importMnemonic")) {
      String mnemonic = call.arguments("mnemonic");
      String path = call.arguments("path");
      String password = call.arguments("password");
      String symbolString = call.arguments("symbols");
      try {
        Wallet.validateMnemonic(mnemonic);
      } catch (Exception e) {
        return result.error("PARAMETER_ERROR", "Mnemonic is invalid");
      }
      Wallet_ wallet;
      try {
        wallet = this.getWalletInstance(mnemonic, path, password);
      } catch (Exception e) {
        return result.error("PROCESS_ERROR", "Unknown error when importing mnemonic");
      }
      Array<String> symbols = symbolString.split(",", 0);
      HashMap<String, HashMap<String, String>> keyInfo = new HashMap<String, HashMap<String, String>>();
      for (String symbol : symbols) {
        HashMap<String, String> keys = new HashMap<String, String>();
        keys.put("publicKey", wallet.derivePublicKey(symbol));
        keys.put("address", wallet.deriveAddress(symbol));

        keyInfo.put(symbol, keys);
      }
      result.success(keyInfo);
    } else if (call.method.equals("signTx")) {
      String mnemonic = call.arguments("mnemonic");
      String rawTx = call.arguments("rawTx"); 
      String path = call.arguments("path");
      String password = call.arguments("password");
      String symbol = call.arguments("symbol");
      try {
        Wallet.validateMnemonic(mnemonic);
      } catch (Exception e) {
        return result.error("PARAMETER_ERROR", "Mnemonic is invalid");
      }
      Wallet_ wallet;
      try {
        String signTx = this.signTx(mnemonic, path, password, symbol, rawTx);
      } catch (Exception e) {
        return result.error("PROCESS_ERROR", "Unknown error when signing");
      }
      result.success(signTx);
    } else {
      result.notImplemented();
    }
  }

  private String generateMnemonic() {
    return Wallet.newMnemonic();
  }

  /**
  * @params password: salt
  */
  private Wallet_ getWalletInstance(String mnemonic, String path, String password) {
    WalletOptions options = new WalletOptions();
    options.add(Wallet.withPathFormat(path)).add(Wallet.withPassword(password));
    Wallet_ build = Wallet.buildWalletFromMnemonic(mnemonic, false, options);
    return wallet;
  }

  private String signTx(String mnemonic, String path, String password, String symbol, String rawTx) {
    Wallet_ wallet = this.getWalletInstance(mnemonic, path, password);
    return wallet.sign(symbol, rawTx);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
