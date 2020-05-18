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
    NSError* error;
    NSString* mnemonic = [FlutterWalletCorePlugin generateMnemonic, error:&error];

    if (error) {
      result(error);
      return;
    }
    result(mnemonic);
  } else if ([@"importMnemonic" isEqualToString:call.method]) {
    NSString* mnemonic = call.arguments[@"mnemonic"];
    NSString* path = call.arguments[@"path"];
    NSString* password = call.arguments[@"password"];
    NSString* symbolString = call.arguments[@"symbolString"];
    NSError* error;
    WalletWallet* wallet = [FlutterWalletCorePlugin getWalletInstance:mnemonic path:path password:password, error:&error];

    if (error) {
      result(error);
      return;
    }

    NSArray *symbols = [symbolString componentsSeparatedByString: @","];
    NSMutableDictionary *keyInfo = [NSMutableDictionary dictionaryWithCapacity:[symbols count]];

    for (NSString *symbol in symbols) {
      NSMutableDictionary *keys = [NSMutableDictionary dictionaryWithCapacity:2];
      keys[@"publicKey"] = [wallet derivePublicKey:symbol error:&error];
      if (error) {
        result(error);
        return;
      } 
      keys[@"address"] = [wallet deriveAddress:symbol error:&error];
      if (error) {
        result(error);
        return;
      } 

      keyInfo[symbol] = keys;
    }
    result(keyInfo);
  } else if ([@"signTx" isEqualToString:call.method]) {
    NSString* mnemonic = call.arguments[@"mnemonic"];
    NSString* path = call.arguments[@"path"];
    NSString* password = call.arguments[@"password"];
    NSString* symbol = call.arguments[@"symbol"];
    NSString* rawTx = call.arguments[@"rawTx"];
    NSError* error;

    NSString* signedTx = [FlutterWalletCorePlugin signTx:mnemonic path:path password:password symbol:symbol rawTx:rawTx, error:&error];

    if (error) {
      result(error);
      return;
    }
    result(signedTx);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

+ (NSString*)generateMnemonic:(NSError* _Nullable* _Nullable)error {
  NSString* menmonic = WalletNewMnemonic(&error);
  return mnemonic;
}

+ (WalletWallet*) getWalletInstance:(NSString*)mnemonic path:(NSString*)path password:(NSString*)password error:(NSError* _Nullable* _Nullable)error {
    id<WalletWalletOptions> options;
    options.add(WalletWithPathFormat(path));
    options.add(WalletWithPassword(password));

    WalletWallet* wallet = WalletBuildWalletFromMnemonic(mnemonic, false, options, &error);
    return wallet;
}

+ (NSString*) signTx:(NSString*)mnemonic path:(NSString*)path password:(NSString*)password symbol:(NSString*)symbol rawTx:(NSString*)rawTx error:(NSError* _Nullable* _Nullable)error {
    WalletWallet* wallet = getWalletInstance(mnemonic, path, password, &error);
    return wallet.sign(symbol, rawTx, &error);
}

@end
