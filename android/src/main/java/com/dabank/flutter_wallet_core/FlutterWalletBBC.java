package com.dabank.flutter_wallet_core;

import java.util.HashMap;

import bip39.Bip39;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import bbc.Bbc;
import bbc.KeyInfo;

public class FlutterWalletBBC {
    static String[] allFunc = new String[]{"bbcCreateFromMnemonic", "bbcCreateFromPrivateKey", "bbcSignTxWithTemplate"};

    static public void callFunc(MethodCall call, Result result) {
        switch (call.method) {
            case "bbcCreateFromMnemonic":
                bbcCreateFromMnemonic(call, result);
                break;
            case "bbcCreateFromPrivateKey":
                bbcCreateFromPrivateKey(call, result);
                break;
            case "bbcSignTxWithTemplate":
                bbcSignTxWithTemplate(call, result);
                break;
            default:
                result.notImplemented();
        }
    }

    static private HashMap<String, String> keyInfoToMap(KeyInfo info) {
        HashMap<String, String> keyInfo = new HashMap<>();
        keyInfo.put("address", info.getAddress());
        keyInfo.put("publicKey", info.getPublicKey());
        keyInfo.put("privateKey", info.getPrivateKey());
        return keyInfo;
    }


    /**
     * @param call   arguments: salt,mnemonic
     * @param result {address,publicKey,privateKey}
     */
    static private void bbcCreateFromMnemonic(MethodCall call, Result result) {
        try {
            String salt = call.argument("salt");
            String mnemonic = call.argument("mnemonic");
            if (!Bip39.isMnemonicValid(mnemonic)) {
                result.error("PARAMETER_ERROR", "Invalid mnemonic", null);
            } else {
                final byte[] seed = Bip39.newSeed(mnemonic, salt);
                //deriveKey 该函数已失效，请使用 DeriveKeySimple 替换 ,accountIndex, changeType, index 3个参数旧版api也是不会生效的的
                final KeyInfo keyPair = Bbc.deriveKeySimple(seed);
                result.success(keyInfoToMap(keyPair));
            }
        } catch (Exception e) {
            result.error("PROCESS_ERROR", "Unknown error when bbcCreateFromMnemonic", null);
        }
    }

    /**
     * @param call   arguments: privateKey
     * @param result {address,publicKey,privateKey}
     */
    static private void bbcCreateFromPrivateKey(MethodCall call, Result result) {
        try {
            String privateKey = call.argument("privateKey");
            KeyInfo keyPair = Bbc.parsePrivateKey(privateKey);
            result.success(keyInfoToMap(keyPair));
        } catch (Exception e) {
            result.error("PROCESS_ERROR", "Unknown error when bbcCreateFromPrivateKey", null);
        }
    }

    /**
     * @param call   arguments: rawTx,privateKey,templateData
     * @param result signedTX
     */
    static private void bbcSignTxWithTemplate(MethodCall call, Result result) {
        try {
            String rawTx = call.argument("rawTx");
            String privateKey = call.argument("privateKey");
            String templateData = call.argument("templateData");
            String signedTX = Bbc.signWithPrivateKey(rawTx, templateData, privateKey);
            result.success(signedTX);
        } catch (Exception e) {
            result.error("PROCESS_ERROR", "Unknown error when bbcSignTxWithTemplate", null);
        }
    }


}
