// Objective-C API for talking to github.com/dabankio/wallet-core/wallet Go package.
//   gobind -lang=objc github.com/dabankio/wallet-core/wallet
//
// File is generated by gobind. Do not edit.

#ifndef __Wallet_H__
#define __Wallet_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"

#include "Bip44.objc.h"
#include "Bbc.objc.h"
#include "Btc.objc.h"
#include "Eth.objc.h"
#include "Omni.objc.h"
#include "Bip39.objc.h"

@class WalletWallet;
@class WalletWalletBuilder;
@class WalletWalletOptions;
@protocol WalletWalletOption;
@class WalletWalletOption;

@protocol WalletWalletOption <NSObject>
- (BOOL)visit:(WalletWallet* _Nullable)p0 error:(NSError* _Nullable* _Nullable)error;
@end

/**
 * Wallet all in one signer
 */
@interface WalletWallet : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
/**
 * ShareAccountWithParentChain break the HD rule, use the metadata of the parent chain to generate keys and addresses.
 */
@property (nonatomic) BOOL shareAccountWithParentChain;
/**
 * Bip39Seed get bip39 seed,调用该函数后不要求该mnemonic和password
 */
- (NSData* _Nullable)bip39Seed:(NSError* _Nullable* _Nullable)error;
- (WalletWallet* _Nullable)clone:(WalletWalletOptions* _Nullable)options error:(NSError* _Nullable* _Nullable)error;
/**
 * DecodeTx 解析交易数据
return: json 数据
 */
- (NSString* _Nonnull)decodeTx:(NSString* _Nullable)symbol msg:(NSString* _Nullable)msg error:(NSError* _Nullable* _Nullable)error;
/**
 * DeriveAddress 获取对应币种代号的 地址
 */
- (NSString* _Nonnull)deriveAddress:(NSString* _Nullable)symbol error:(NSError* _Nullable* _Nullable)error;
/**
 * DerivePrivateKey 获取对应币种代号的 私钥
 */
- (NSString* _Nonnull)derivePrivateKey:(NSString* _Nullable)symbol error:(NSError* _Nullable* _Nullable)error;
/**
 * DerivePublicKey 获取对应币种代号的 公钥
 */
- (NSString* _Nonnull)derivePublicKey:(NSString* _Nullable)symbol error:(NSError* _Nullable* _Nullable)error;
/**
 * HasFlag 是否存在flag
 */
- (BOOL)hasFlag:(NSString* _Nullable)flag;
// skipped method Wallet.Metadata with unsupported parameter or return types

/**
 * Sign 签名交易
 */
- (NSString* _Nonnull)sign:(NSString* _Nullable)symbol msg:(NSString* _Nullable)msg error:(NSError* _Nullable* _Nullable)error;
@end

@interface WalletWalletBuilder : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
/**
 * NewWalletBuilder normal builder pattern, not so good in golang
 */
- (nullable instancetype)init;
- (WalletWalletBuilder* _Nullable)setMnemonic:(NSString* _Nullable)mnemonic;
- (WalletWalletBuilder* _Nullable)setPassword:(NSString* _Nullable)password;
- (WalletWalletBuilder* _Nullable)setShareAccountWithParentChain:(BOOL)shareAccountWithParentChain;
- (WalletWalletBuilder* _Nullable)setTestNet:(BOOL)testNet;
- (WalletWalletBuilder* _Nullable)setUseShortestPath:(BOOL)useShortestPath;
- (WalletWallet* _Nullable)wallet:(NSError* _Nullable* _Nullable)error;
@end

@interface WalletWalletOptions : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
- (void)add:(id<WalletWalletOption> _Nullable)opt;
@end

/**
 * FlagBBCUseStandardBip44ID BBC使用标准bip44 id (默认不是标准bip44 id)
 */
FOUNDATION_EXPORT NSString* _Nonnull const WalletFlagBBCUseStandardBip44ID;
/**
 * FlagMKFUseBBCBip44ID MKF使用BBC的bip44 id (即MKF和BBC共用地址)
 */
FOUNDATION_EXPORT NSString* _Nonnull const WalletFlagMKFUseBBCBip44ID;

/**
 * BuildWallet create a Wallet instance with fixed args (here is mnemonic and testNet) and other options
 */
FOUNDATION_EXPORT WalletWallet* _Nullable WalletBuildWalletFromMnemonic(NSString* _Nullable mnemonic, BOOL testNet, WalletWalletOptions* _Nullable options, NSError* _Nullable* _Nullable error);

// skipped function BuildWalletFromPrivateKey with unsupported parameter or return types


/**
 * EntropyFromMnemonic 根据 助记词, 获取 Entropy
returns the input entropy used to generate the given mnemonic
 */
FOUNDATION_EXPORT NSString* _Nonnull WalletEntropyFromMnemonic(NSString* _Nullable mnemonic, NSError* _Nullable* _Nullable error);

/**
 * GetAvailableCoinList 获取支持币种列表 (case sensitive)
return : "BTC LMC ETH WCG"
 */
FOUNDATION_EXPORT NSString* _Nonnull WalletGetAvailableCoinList(void);

FOUNDATION_EXPORT NSString* _Nonnull WalletGetBuildTime(void);

FOUNDATION_EXPORT NSString* _Nonnull WalletGetGitHash(void);

FOUNDATION_EXPORT NSString* _Nonnull WalletGetVersion(void);

/**
 * MnemonicFromEntropy 根据 entropy， 获取对应助记词
 */
FOUNDATION_EXPORT NSString* _Nonnull WalletMnemonicFromEntropy(NSString* _Nullable entropy, NSError* _Nullable* _Nullable error);

/**
 * NewHDWalletFromMnemonic 通过助记词得到一个 HD 对象
 */
FOUNDATION_EXPORT WalletWallet* _Nullable WalletNewHDWalletFromMnemonic(NSString* _Nullable mnemonic, NSString* _Nullable password, BOOL testNet, NSError* _Nullable* _Nullable error);

/**
 * NewMnemonic 生成助记词
默认使用128位密钥，生成12个单词的助记词
 */
FOUNDATION_EXPORT NSString* _Nonnull WalletNewMnemonic(NSError* _Nullable* _Nullable error);

/**
 * NewWalletBuilder normal builder pattern, not so good in golang
 */
FOUNDATION_EXPORT WalletWalletBuilder* _Nullable WalletNewWalletBuilder(void);

/**
 * ValidateMnemonic 验证助记词的正确性
 */
FOUNDATION_EXPORT BOOL WalletValidateMnemonic(NSString* _Nullable mnemonic, NSError* _Nullable* _Nullable error);

/**
 * WithFlag 该选项添加特殊配置flag, flag参考 FlagXXX 常量
 */
FOUNDATION_EXPORT id<WalletWalletOption> _Nullable WalletWithFlag(NSString* _Nullable flag);

FOUNDATION_EXPORT id<WalletWalletOption> _Nullable WalletWithPassword(NSString* _Nullable password);

FOUNDATION_EXPORT id<WalletWalletOption> _Nullable WalletWithPathFormat(NSString* _Nullable pathFormat);

FOUNDATION_EXPORT id<WalletWalletOption> _Nullable WalletWithShareAccountWithParentChain(BOOL shareAccountWithParentChain);

@class WalletWalletOption;

@interface WalletWalletOption : NSObject <goSeqRefInterface, WalletWalletOption> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (BOOL)visit:(WalletWallet* _Nullable)p0 error:(NSError* _Nullable* _Nullable)error;
@end

#endif
