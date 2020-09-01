#import "WalletBbc.h"
#import <Bip39/Bbc.objc.h>
#import "StringUtils.h"

@interface WalletBbc ()

@property (nonatomic, strong) NSDictionary *defaultOptions;
@property (nonatomic, retain) NSMutableDictionary *options;
@property (nonatomic, strong) NSString *clientRef;

@end

@implementation WalletBbc

+ (NSMutableDictionary*) createNew:(NSString*)salt
                             error:(NSError*_Nullable __autoreleasing *_Nullable)error {
    
    NSData* entropy = Bip39NewEntropy(128, error);
    NSString* mnemonic = Bip39NewMnemonic(entropy, error);
    
    NSData* seed = Bip39NewSeed(mnemonic, salt);
    BbcKeyInfo * keyInfo = BbcDeriveKeySimple(seed, error);
    
    NSMutableDictionary *retDict = [NSMutableDictionary dictionaryWithCapacity:4];
    retDict[@"mnemonic"] = mnemonic;
    retDict[@"address"] = keyInfo.address;
    retDict[@"privateKey"] = keyInfo.privateKey;
    retDict[@"publicKey"] = keyInfo.publicKey;
    
    return retDict;
}

+ (NSMutableDictionary*) createFromPrivateKey:(NSString*)privateKey
                                        error:(NSError*_Nullable __autoreleasing *_Nullable)error {
    
    BbcKeyInfo * keyInfo = BbcParsePrivateKey(privateKey, error);

    NSMutableDictionary *retDict = [NSMutableDictionary dictionaryWithCapacity:3];

    retDict[@"address"] = keyInfo.address;
    retDict[@"privateKey"] = keyInfo.privateKey;
    retDict[@"publicKey"] = keyInfo.publicKey;

    return retDict;
}

+ (NSMutableDictionary*) createFromMnemonic:(NSString*)mnemonic
                                       salt:(NSString*)salt
                                      error:(NSError*_Nullable __autoreleasing *_Nullable)error {
    
    NSMutableDictionary *retDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if (!Bip39IsMnemonicValid(mnemonic)) {
        NSDictionary *details = [NSDictionary dictionaryWithObject:@"Invalid Mnemonic"
                                                             forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"WalletBbc" code:200 userInfo:details];
    } else {
        NSData* seed = Bip39NewSeed(mnemonic, salt);
        BbcKeyInfo * keyInfo = BbcDeriveKeySimple(seed, error);

        retDict[@"address"] = keyInfo.address;
        retDict[@"privateKey"] = keyInfo.privateKey;
        retDict[@"publicKey"] = keyInfo.publicKey;

        return retDict;
    }

    return retDict;
}


+ (NSString*) signTransaction:(NSString*)txString
                              privateKey:(NSString*) privateKey
                                   error:(NSError*_Nullable __autoreleasing *_Nullable)error {

    NSString* signedTransaction = BbcSignWithPrivateKey(txString, NULL, privateKey, error);

    return signedTransaction;
}


+ (NSString*) signTransactionWithTemplate:(NSString*)txString
                             templateData:(NSString*) templateData
                              privateKey:(NSString*) privateKey
                                   error:(NSError*_Nullable __autoreleasing *_Nullable)error {
    
    NSLog(@"txString:%@",txString);
    NSLog(@"templateData:%@",templateData);
    NSLog(@"privateKey:%@",privateKey);

    NSString* signTransactionWithTemplate = BbcSignWithPrivateKey(txString, templateData, privateKey, error);

    return signTransactionWithTemplate;
}


+ (NSString*) buildTransaction:(NSDictionary *) map
                         error:(NSError*_Nullable __autoreleasing *_Nullable)error {
    
    NSArray* utxos = map[@"utxos"];
    NSString* address = [map[@"address"] stringValue];
    NSString* anchor = [map[@"anchor"] stringValue];
    double amount = [map[@"amount"] doubleValue];
    double fee = [map[@"fee"] doubleValue];
    int version = [map[@"version"] intValue];
    int lockUntil = [map[@"lockUntil"] intValue];
    long timestamp = [map[@"timestamp"] longLongValue];
    NSString* data = [map[@"data"] stringValue];
    NSString* dataUUID = [map[@"dataUUID"] stringValue];
           
    BbcTxBuilder *txBuilder = BbcNewTxBuilder();
    [txBuilder setAnchor:(anchor)];
    [txBuilder setTimestamp:(timestamp)];
    [txBuilder setVersion:(version)];
    [txBuilder setLockUntil:(lockUntil)];
    [txBuilder setAddress:(address)];
    [txBuilder setAmount:(amount)];
    [txBuilder setFee:(fee)];
    if (data) {
       if (dataUUID) {
           [txBuilder setDataWithUUID:(dataUUID) timestamp:(timestamp) data:(data)];
       } else {
           [txBuilder setStringData:(data)];
       }
    }
    for (int i = 0; i < utxos.count; i++) {
       NSDictionary* utxo = utxos[i];
       NSString* txid = [utxo[@"txid"] stringValue];
       int vout = [utxo[@"vout"] intValue];
       [txBuilder addInput:(txid) vout:(vout)];
    }

    NSString* hex = [txBuilder build:(error)];
    
    return hex;
}


+ (NSString*) addresssToPublicKey:(NSString *) address
                     error:(NSError*_Nullable __autoreleasing *_Nullable)error {

    NSString* publicKey = BbcAddress2pubk(address, error);

    return publicKey;
}

+ (NSString*) convertHexStrToBase64:(NSString *) hex1
                               hex2:(NSString*) hex2
                              error:(NSError*_Nullable __autoreleasing *_Nullable)error {

    NSMutableData *hexData =  [[NSMutableData alloc] initWithCapacity:8];

    if (hex1) {
        NSData *hexData1 = hexString2Data(hex1);
        NSData *newData = reverseData(hexData1);
        [hexData appendData:newData];
    }

    if (hex2) {
        NSData *hexData2 = hexString2Data(hex2);
        NSData *newData = reverseData(hexData2);
        [hexData appendData:newData];
    }

    NSString *base64String = [hexData base64EncodedStringWithOptions: 0];

    return base64String;
}

@end
