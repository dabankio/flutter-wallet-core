#import "FlutterWalletCorePlugin.h"
#import <Bip39/Wallet.objc.h>
#import <WalletBbc.h>

@implementation FlutterWalletCorePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:@"flutter_wallet_core"
                                   binaryMessenger:[registrar messenger]];
  FlutterWalletCorePlugin* instance = [[FlutterWalletCorePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSError* __autoreleasing error;
    
    // Mathods mapping
  if ([@"generateMnemonic" isEqualToString:call.method]) {
    NSString* mnemonic = [FlutterWalletCorePlugin generateMnemonic:&error];
    if (error) {
      result([FlutterError errorWithCode:@"generateMnemonicError" message:error.localizedDescription details:nil]);
      return;
    }
    result(mnemonic);
  } else if ([@"importMnemonic" isEqualToString:call.method]) {
    NSString* mnemonic = call.arguments[@"mnemonic"];
    NSString* path = call.arguments[@"path"];
    NSString* password = call.arguments[@"password"];
    NSString* symbolString = call.arguments[@"symbols"];
    NSNumber* beta = call.arguments[@"beta"];
    NSNumber* shareAccountWithParentChain = call.arguments[@"shareAccountWithParentChain"];
   NSNumber* useBip44 = call.arguments[@"useBip44"];


    WalletValidateMnemonic(mnemonic, &error);

    if (error) {
      result([FlutterError errorWithCode:@"PARAMETER_ERROR" message:@"Mnemonic is invalid" details:nil]);
      return;
    }

      WalletWallet* wallet = [FlutterWalletCorePlugin getWalletInstance: useBip44 mnemonic:mnemonic path:path password:password beta:beta shareAccountWithParentChain:shareAccountWithParentChain error:&error];

    if (error) {
      result([FlutterError errorWithCode:@"importMnemonicError" message:error.localizedDescription details:nil]);
      return;
    }

    NSString* publicKey = [wallet derivePublicKey:@"BTC" error:&error];

    NSArray *symbols = [symbolString componentsSeparatedByString: @","];
    NSMutableDictionary *keyInfo = [NSMutableDictionary dictionaryWithCapacity:[symbols count]];

    for (NSString *symbol in symbols) {
      NSMutableDictionary *keys = [NSMutableDictionary dictionaryWithCapacity:2];
      keys[@"publicKey"] = [wallet derivePublicKey:symbol error:&error];
      if (error) {
        result([FlutterError errorWithCode:@"derivePublicKeyError" message:error.localizedDescription details:nil]);
        return;
      } 
      keys[@"address"] = [wallet deriveAddress:symbol error:&error];
      if (error) {
        result([FlutterError errorWithCode:@"deriveAddressError" message:error.localizedDescription details:nil]);
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
    NSNumber* beta = call.arguments[@"beta"];
    NSNumber* shareAccountWithParentChain = call.arguments[@"shareAccountWithParentChain"];
    NSNumber* useBip44 = call.arguments[@"useBip44"];

    WalletValidateMnemonic(mnemonic, &error);

    if (error) {
      result([FlutterError errorWithCode:@"PARAMETER_ERROR" message:@"Mnemonic is invalid" details:nil]);
      return;
    }

      NSString* signedTx = [FlutterWalletCorePlugin signTx: useBip44 mnemonic:mnemonic path:path password:password symbol:symbol rawTx:rawTx beta:beta shareAccountWithParentChain:shareAccountWithParentChain error:&error];

    if (error) {
      result([FlutterError errorWithCode:@"signError" message:error.localizedDescription details:nil]);
      return;
    }
    result(signedTx);
  } else if([@"bbcCreateFromPrivateKey" isEqualToString:call.method]) {
      NSString* privateKey = call.arguments[@"privateKey"];

      NSMutableDictionary* data = [WalletBbc createFromPrivateKey:privateKey error:&error];
      if (error) {
        result([FlutterError errorWithCode:@"bbcCreateFromPrivateKey" message:error.localizedDescription details:nil]);
        return;
      }
      result(data);
  } else if([@"bbcCreateFromMnemonic" isEqualToString:call.method]) {
      NSString* salt = call.arguments[@"salt"];
      NSString* mnemonic = call.arguments[@"mnemonic"];

      NSMutableDictionary* data = [WalletBbc createFromMnemonic:mnemonic salt:salt error:&error];
      if (error) {
        result([FlutterError errorWithCode:@"createFromMnemonic" message:error.localizedDescription details:nil]);
        return;
      }
      result(data);
  } else if([@"bbcSignTxWithTemplate" isEqualToString:call.method]) {
      NSString* rawTx = call.arguments[@"rawTx"];
      NSString* templateData = call.arguments[@"templateData"];
      NSString* privateKey = call.arguments[@"privateKey"];

      NSString* data = [WalletBbc signTransactionWithTemplate:rawTx
                                                 templateData:templateData
                                                   privateKey:privateKey
                                                        error:&error];
      if (error) {
        result([FlutterError errorWithCode:@"createFromMnemonic" message:error.localizedDescription details:nil]);
        return;
      }
      result(data);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

+ (NSString*)generateMnemonic:(NSError * _Nullable __autoreleasing * _Nullable)error {
  NSString* mnemonic = WalletNewMnemonic(error);
  return mnemonic;
}

+ (WalletWallet*) getWalletInstance: (BOOL)useBip44 mnemonic:(NSString*)mnemonic path:(NSString*)path password:(NSString*)password beta:(BOOL) beta shareAccountWithParentChain:(BOOL) shareAccountWithParentChain  error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    WalletWalletOptions* options = [WalletWalletOptions new];
    id<WalletWalletOption> pathOption = WalletWithPathFormat(path);
    id<WalletWalletOption> passwordOption = WalletWithPassword(password);
    id<WalletWalletOption> shareAccountWithParentChainOption = WalletWithShareAccountWithParentChain(shareAccountWithParentChain);
    [options add:pathOption];
    [options add:passwordOption];
    [options add:shareAccountWithParentChainOption];
    
    if (useBip44) {
        [options add:WalletWithFlag(WalletFlagBBCUseStandardBip44ID)];
        [options add:WalletWithFlag(WalletFlagMKFUseBBCBip44ID)];
    }

    WalletWallet* wallet = WalletBuildWalletFromMnemonic(mnemonic, beta, options, error);
    return wallet;
}

+ (NSString*) signTx:(BOOL)useBip44 mnemonic:(NSString*)mnemonic path:(NSString*)path password:(NSString*)password symbol:(NSString*)symbol rawTx:(NSString*)rawTx beta:(BOOL) beta shareAccountWithParentChain:(BOOL) shareAccountWithParentChain error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    WalletWallet* wallet = [FlutterWalletCorePlugin getWalletInstance:useBip44 mnemonic:mnemonic path:path password:password beta:beta shareAccountWithParentChain:shareAccountWithParentChain error:error];
    return [wallet sign:symbol msg:rawTx error:error];
}

@end
