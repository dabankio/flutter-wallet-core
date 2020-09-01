package com.dabank.flutter_wallet_core;

import androidx.annotation.NonNull;

import java.util.Arrays;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import wallet.Wallet;
import wallet.WalletOptions;
import wallet.Wallet_;

/**
 * FlutterWalletCorePlugin
 */
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
      String mnemonic = call.argument("mnemonic");
      String path = call.argument("path");
      String password = call.argument("password");
      String symbolString = call.argument("symbols");
      boolean beta = call.argument("beta");
      boolean shareAccountWithParentChain = call.argument("shareAccountWithParentChain");
      try {
        Wallet.validateMnemonic(mnemonic);
      } catch (Exception e) {
        result.error("PARAMETER_ERROR", "Mnemonic is invalid", null);
        return;
      }
      Wallet_ wallet;
      try {
        wallet = this.getWalletInstance(mnemonic, path, password, beta, shareAccountWithParentChain);
      } catch (Exception e) {
        result.error("PROCESS_ERROR", "Unknown error when importing mnemonic", null);
        return;
      }
      String[] symbols = symbolString.split(",", 0);
      HashMap<String, HashMap<String, String>> keyInfo = new HashMap<String, HashMap<String, String>>();
      for (String symbol : symbols) {
        HashMap<String, String> keys = new HashMap<String, String>();
        try {
          keys.put("publicKey", wallet.derivePublicKey(symbol));
          keys.put("address", wallet.deriveAddress(symbol));
        } catch (Exception e) {
          e.printStackTrace();
        }
        keyInfo.put(symbol, keys);
      }
      result.success(keyInfo);
    } else if (call.method.equals("signTx")) {
      String mnemonic = call.argument("mnemonic");
      String rawTx = call.argument("rawTx");
      String path = call.argument("path");
      String password = call.argument("password");
      String symbol = call.argument("symbol");
      boolean beta = call.argument("beta");
      boolean shareAccountWithParentChain = call.argument("shareAccountWithParentChain");
      try {
        Wallet.validateMnemonic(mnemonic);
      } catch (Exception e) {
        result.error("PARAMETER_ERROR", "Mnemonic is invalid", null);
        return;
      }
      Wallet_ wallet;
      String signTx = "";
      try {
        signTx = this.signTx(mnemonic, path, password, symbol, rawTx, beta, shareAccountWithParentChain);
      } catch (Exception e) {
        result.error("PROCESS_ERROR", "Unknown error when signing", null);
        return;
      }
      result.success(signTx);
    } else if (Arrays.asList(FlutterWalletBBC.allFunc).contains(call.method))  {
       FlutterWalletBBC.callFunc(call,result);
    }else{
      result.notImplemented();
    }
  }

  private String generateMnemonic() {
    try {
      return Wallet.newMnemonic();
    } catch (Exception e) {
      e.printStackTrace();
      return "";
    }
  }

  /**
    * @params password: salt
    */
  private Wallet_ getWalletInstance(
          String mnemonic, String path,
          String password, boolean beta,
          boolean shareAccountWithParentChain
  ) {
    WalletOptions options = new WalletOptions();
    options.add(Wallet.withPathFormat(path));
    options.add(Wallet.withPassword(password));
    options.add(Wallet.withShareAccountWithParentChain(shareAccountWithParentChain));
    Wallet_ wallet = null;
    try {
      wallet = Wallet.buildWalletFromMnemonic(mnemonic, beta, options);
    } catch (Exception e) {
      e.printStackTrace();
    }
    return wallet;
  }

  private String signTx(String mnemonic, String path, String password, String symbol, String rawTx, boolean beta, boolean shareAccountWithParentChain) {
    Wallet_ wallet = this.getWalletInstance(mnemonic, path, password, beta, shareAccountWithParentChain);
    try {
      return wallet.sign(symbol, rawTx);
    } catch (Exception e) {
      e.printStackTrace();
      return "";
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
