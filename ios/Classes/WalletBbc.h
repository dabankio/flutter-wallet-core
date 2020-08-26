#import <Foundation/Foundation.h>

@interface WalletBbc : NSObject


+ (NSMutableDictionary*_Nullable)createNew:(NSString*_Nonnull)salt
                                     error:(NSError*_Nullable __autoreleasing *_Nullable)error;

/**
 importPrivateKey and return wallet info
*/
+ (NSMutableDictionary*_Nullable)createFromPrivateKey:(NSString*_Nonnull)privateKey
                                                error:(NSError*_Nullable __autoreleasing *_Nullable)error;

+ (NSMutableDictionary*_Nullable)createFromMnemonic:(NSString*_Nonnull)mnemonic
                                               salt:(NSString*_Nonnull)salt
                                              error:(NSError*_Nullable __autoreleasing *_Nullable)error;


+ (NSString*_Nonnull) signTransaction:(NSString*_Nonnull)txString
                           privateKey:(NSString*_Nonnull) privateKey
                                error:(NSError*_Nullable __autoreleasing *_Nullable)error;


+ (NSString*_Nonnull) signTransactionWithTemplate:(NSString*_Nonnull)txString
                                     templateData:(NSString*_Nonnull) templateData
                                       privateKey:(NSString*_Nonnull) privateKey
                                            error:(NSError*_Nullable __autoreleasing *_Nullable)error;

+ (NSString*_Nonnull) buildTransaction:(NSDictionary *_Nonnull) map
                                 error:(NSError*_Nullable __autoreleasing *_Nullable)error;

+ (NSString*_Nonnull) addresssToPublicKey:(NSString *_Nonnull) address
                            error:(NSError*_Nullable __autoreleasing *_Nullable)error;
    

+ (NSString*_Nonnull) convertHexStrToBase64:(NSString *_Nonnull) hex1
                               hex2:(NSString*_Nonnull) hex2
                              error:(NSError*_Nullable __autoreleasing *_Nullable)error;
@end
