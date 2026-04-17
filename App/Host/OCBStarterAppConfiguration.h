#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBAPIResponseMapper;
@class OCBTabBarItemDescriptor;

@interface OCBStarterAppConfiguration : NSObject

+ (NSString *)defaultEnvironment;
+ (NSArray<OCBTabBarItemDescriptor *> *)starterTabs;
+ (NSDictionary<NSString *, NSURL *> *)networkBaseURLsByEnvironment;
+ (NSDictionary<NSString *, NSString *> *)networkCommonHeaders;
+ (void)configureAPIResponseMapper:(OCBAPIResponseMapper *)mapper;
+ (NSDictionary<NSString *, id> *)bootstrapRemoteConfig;
+ (nullable NSURL *)baseURLForEnvironment:(NSString *)environment;

@end

NS_ASSUME_NONNULL_END
