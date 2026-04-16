#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCBAppMetadata : NSObject

+ (NSString *)displayName;
+ (NSString *)bundleIdentifier;
+ (NSString *)versionString;
+ (NSString *)buildString;
+ (NSString *)versionDisplayString;

@end

NS_ASSUME_NONNULL_END
