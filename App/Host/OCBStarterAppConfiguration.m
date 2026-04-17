#import "OCBStarterAppConfiguration.h"

#import "OCBAPIResponseMapper.h"
#import "OCBDemoRouteCatalog.h"
#import "OCBTabBarItemDescriptor.h"

@implementation OCBStarterAppConfiguration

+ (NSString *)defaultEnvironment
{
    return @"development";
}

+ (NSArray<OCBTabBarItemDescriptor *> *)starterTabs
{
    return @[
        [OCBTabBarItemDescriptor itemWithTitle:@"Home"
                                     routePath:OCBDemoRouteHome
                               systemImageName:@"house"
                       selectedSystemImageName:@"house.fill"],
        [OCBTabBarItemDescriptor itemWithTitle:@"Profile"
                                     routePath:OCBDemoRouteProfile
                               systemImageName:@"person.crop.circle"
                       selectedSystemImageName:@"person.crop.circle.fill"],
        [OCBTabBarItemDescriptor itemWithTitle:@"Account"
                                     routePath:OCBDemoRouteAccount
                               systemImageName:@"gearshape"
                       selectedSystemImageName:@"gearshape.fill"]
    ];
}

+ (NSDictionary<NSString *,NSURL *> *)networkBaseURLsByEnvironment
{
    return @{
        @"development": [NSURL URLWithString:@"https://dev.example.com"],
        @"staging": [NSURL URLWithString:@"https://staging.example.com"],
        @"production": [NSURL URLWithString:@"https://example.com"]
    };
}

+ (NSDictionary<NSString *,NSString *> *)networkCommonHeaders
{
    return @{
        @"X-OCB-App": @"OCAppBox"
    };
}

+ (void)configureAPIResponseMapper:(OCBAPIResponseMapper *)mapper
{
    mapper.codeKeyPath = @"code";
    mapper.messageKeyPath = @"message";
    mapper.dataKeyPath = @"data";
    mapper.successKeyPath = @"success";
    mapper.successCodes = @[@0, @200];
    mapper.treatMissingBusinessCodeAsSuccess = YES;
}

+ (NSDictionary<NSString *,id> *)bootstrapRemoteConfig
{
    return @{
        @"home.headline": @"Starter App Ready",
        @"home.welcome.copy": @"默认 TabBar、基础服务和网络环境已经接好，可以直接开始填业务页面。",
        @"feature.empty_state_demo": @YES
    };
}

+ (nullable NSURL *)baseURLForEnvironment:(NSString *)environment
{
    if (environment.length == 0) {
        return nil;
    }

    return [self networkBaseURLsByEnvironment][environment];
}

@end
