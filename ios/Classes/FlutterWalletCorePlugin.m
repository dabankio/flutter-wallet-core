#import "FlutterWalletCorePlugin.h"
#import <bip39/Wallet.objc.h>

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
    NSError* __autoreleasing error;
    NSString* mnemonic = [FlutterWalletCorePlugin generateMnemonic:&error];

    if (error) {
      result(error);
      return;
    }
    result(mnemonic);
  } else if ([@"importMnemonic" isEqualToString:call.method]) {
    NSString* mnemonic = call.arguments[@"mnemonic"];
    NSString* path = call.arguments[@"path"];
    NSString* password = call.arguments[@"password"];
    NSString* symbolString = call.arguments[@"symbols"];
    NSError* __autoreleasing error;
    WalletWallet* wallet = [FlutterWalletCorePlugin getWalletInstance:mnemonic path:path password:password error:&error];

    if (error) {
      result(error);
      return;
    }

    NSString* publicKey = [wallet derivePublicKey:@"BTC" error:&error];

    result(publicKey);

//     NSArray *symbols = [symbolString componentsSeparatedByString: @","];
//     NSMutableDictionary *keyInfo = [NSMutableDictionary dictionaryWithCapacity:[symbols count]];

//     for (NSString *symbol in symbols) {
//       NSMutableDictionary *keys = [NSMutableDictionary dictionaryWithCapacity:2];
//       keys[@"publicKey"] = [wallet derivePublicKey:symbol error:&error];
//       if (error) {
//           result([FlutterError errorWithCode:@"derivePublicKeyError" message:error.localizedDescription details:nil]);
//         return;
//       } 
//       keys[@"address"] = [wallet deriveAddress:symbol error:&error];
//       if (error) {
// //          result([FlutterError errorWithCode:error.code]);
//         return;
//       } 

//       keyInfo[symbol] = keys;
//     }
//     result(keyInfo);
  } else if ([@"signTx" isEqualToString:call.method]) {
    NSString* mnemonic = call.arguments[@"mnemonic"];
    NSString* path = call.arguments[@"path"];
    NSString* password = call.arguments[@"password"];
    NSString* symbol = call.arguments[@"symbol"];
    NSString* rawTx = call.arguments[@"rawTx"];
    NSError* __autoreleasing error;

    NSString* signedTx = [FlutterWalletCorePlugin signTx:mnemonic path:path password:password symbol:symbol rawTx:rawTx error:&error];

    if (error) {
//      result([FlutterError errorWithCode:error.code]);
      return;
    }
    result(signedTx);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

+ (NSString*)generateMnemonic:(NSError * _Nullable __autoreleasing * _Nullable)error {
  NSString* mnemonic = WalletNewMnemonic(error);
  return mnemonic;
}

+ (WalletWallet*) getWalletInstance:(NSString*)mnemonic path:(NSString*)path password:(NSString*)password error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    WalletWalletOptions* options = [WalletWalletOptions new];
    id<WalletWalletOption> pathOption = WalletWithPathFormat(path);
    id<WalletWalletOption> passwordOption = WalletWithPathFormat(password);
    [options add:pathOption];
    [options add:passwordOption];

    WalletWallet* wallet = WalletBuildWalletFromMnemonic(mnemonic, false, options, error);
    return wallet;
}

+ (NSString*) signTx:(NSString*)mnemonic path:(NSString*)path password:(NSString*)password symbol:(NSString*)symbol rawTx:(NSString*)rawTx error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    WalletWallet* wallet = [FlutterWalletCorePlugin getWalletInstance:mnemonic path:path password:password error:error];
    return [wallet sign:symbol msg:rawTx error:error];
}

@end
