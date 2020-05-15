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
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"importMnemonic" isEqualToString:call.method]) {
  } else if ([@"signTx" isEqualToString:call.method]) {
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL)isStringValid:(NSString*) str {
  return str == (id)[NSNull null] || str.length == 0;
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

- (WalletWallet*) importMnemonic:(NSString*)mnemonic path:(NSString*)path password:(NSString*)password {
    NSError * __autoreleaseing error;

    id<WalletWalletOptions> options;
    options.add(WalletWithPathFormat(path));
    options.add(WalletWithPassword(password));

    WalletWallet* wallet = WalletBuildWalletFromMnemonic(mnemonic, false, options, &error);
    return wallet;
}

- (NSString*) signTx:(NSString*)mnemonic path:(NSString*)path password:(NSString*)password symbol:(NSString*)symbol rawTx:(NSString*)rawTx {
    WalletWallet* wallet = importMnemonic(mnemonic, path, password);
    return wallet.sign(symbol, rawTx);
}

@end
