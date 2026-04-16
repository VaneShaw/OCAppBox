#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OCBLogging;
@protocol OCBStorageProviding;

FOUNDATION_EXPORT NSString * const OCBRemoteConfigDidChangeNotification;

@protocol OCBRemoteConfigProviding <NSObject>

- (NSDictionary<NSString *, id> *)allValues;
- (nullable NSString *)stringValueForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue;
- (BOOL)boolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (NSInteger)integerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;

@end

@protocol OCBMutableRemoteConfigProviding <OCBRemoteConfigProviding>

- (void)applyConfigDictionary:(NSDictionary<NSString *, id> *)config;

@end

@interface OCBRemoteConfigService : NSObject <OCBMutableRemoteConfigProviding>

- (instancetype)initWithStorage:(id<OCBStorageProviding>)storage
                         logger:(id<OCBLogging>)logger NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
