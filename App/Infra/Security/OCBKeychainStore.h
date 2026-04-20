#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OCBKeychainStoring <NSObject>

/// 存储较小的敏感字符串。`account` 在 `serviceIdentifier` 命名空间内唯一。
- (BOOL)setString:(nullable NSString *)value forAccount:(NSString *)account error:(NSError *__autoreleasing _Nullable *_Nullable)error;

- (nullable NSString *)stringForAccount:(NSString *)account error:(NSError *__autoreleasing _Nullable *_Nullable)error;

- (BOOL)removeStringForAccount:(NSString *)account error:(NSError *__autoreleasing _Nullable *_Nullable)error;

@end

@interface OCBKeychainStore : NSObject <OCBKeychainStoring>

- (instancetype)initWithServiceIdentifier:(NSString *)serviceIdentifier NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
