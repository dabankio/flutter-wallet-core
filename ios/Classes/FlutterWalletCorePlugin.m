#import "FlutterWalletCorePlugin.h"
#import <wallet/Wallet.objc.h>

@implementation FlutterWalletCorePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_wallet_core"
            binaryMessenger:[registrar messenger]];
  FlutterWalletCorePlugin* instance = [[FlutterWalletCorePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"generateMnemonic" isEqualToString:call.method]) {
    NSString* mnemonic = generateMnemonic();
    result(mnemonic);
  } else if ([@"importMnemonic" isEqualToString:call.method]) {
    NSString* mnemonic = call.arguments[@"mnemonic"];
    NSString* path = call.arguments[@"path"];
    NSString* password = call.arguments[@"password"];
    NSString* symbolString = call.arguments[@"symbolString"];
    WalletWallet* wallet = getWalletInstance(mnemonic, path, password);

    NSArray *symbols = [string componentsSeparatedByString: @","];
    NSMutableDictionary keyInfo = [NSMutableDictionary dictionaryWithCapacity:symbols.length];

    for (NSString *symbol in symbols) {
      NSMutableDictionary keys = [NSMutableDictionary dictionaryWithCapacity:2];
      keys[@"publicKey"] = wallet.derivePublicKey(symbol);
      keys[@"address"] = wallet.deriveAddress(symbol);

      keyInfo[@symbol] = keys;
    }
    result(keyInfo);
  } else if ([@"signTx" isEqualToString:call.method]) {
    NSString* mnemonic = call.arguments[@"mnemonic"];
    NSString* path = call.arguments[@"path"];
    NSString* password = call.arguments[@"password"];
    NSString* symbol = call.arguments[@"symbol"];
    NSString* rawTx = call.arguments[@"rawTx"];

    NSString* signedTx = signTx(mnemonic, path, password, symbol, rawTx);

    result(signedTx);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSString*)generateMnemonic {
  NSError * __autoreleaseing error;

  NSString* menmonic WalletNewMnemonic(&error);

  if (error) {
    result(error);
  } else {
    result(mnemonic);
  }
}

- (WalletWallet*) getWalletInstance:(NSString*)mnemonic path:(NSString*)path password:(NSString*)password {
    NSError * __autoreleaseing error;

    id<WalletWalletOptions> options;
    options.add(WalletWithPathFormat(path));
    options.add(WalletWithPassword(password));

    WalletWallet* wallet = WalletBuildWalletFromMnemonic(mnemonic, false, options, &error);
    return wallet;
}

- (NSString*) signTx:(NSString*)mnemonic path:(NSString*)path password:(NSString*)password symbol:(NSString*)symbol rawTx:(NSString*)rawTx {
    WalletWallet* wallet = getWalletInstance(mnemonic, path, password);
    return wallet.sign(symbol, rawTx);
}

@end
