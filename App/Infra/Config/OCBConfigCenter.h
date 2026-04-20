#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 本地持久化偏好（NSUserDefaults + 统一 key 前缀），与远端下发的 `OCBRemoteConfigService` 互补；勿存敏感信息。
@protocol OCBConfigProviding <NSObject>

- (nullable id)objectForKey:(NSString *)key;

/// `object` 须为属性列表合法类型（NSString / NSNumber / NSDate / NSData / NSArray / NSDictionary）。
- (void)setObject:(nullable id)object forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (nullable NSString *)stringForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue;
- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;

@end

@interface OCBConfigCenter : NSObject <OCBConfigProviding>

@end

NS_ASSUME_NONNULL_END
