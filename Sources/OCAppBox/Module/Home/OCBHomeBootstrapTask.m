#import "OCBHomeBootstrapTask.h"

#import "OCBAppContext.h"
#import "OCBServiceRegistry.h"
#import "OCBLogger.h"
#import "OCBRemoteConfigService.h"

@implementation OCBHomeBootstrapTask

- (NSString *)taskIdentifier
{
    return @"module.home.bootstrap";
}

- (OCBLaunchStage)stage
{
    return OCBLaunchStageModule;
}

- (NSInteger)priority
{
    return 100;
}

- (void)performWithAppContext:(OCBAppContext *)appContext
                launchOptions:(NSDictionary *)launchOptions
{
    id<OCBLogging> logger = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBLogging)];
    id<OCBMutableRemoteConfigProviding> remoteConfigService = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBMutableRemoteConfigProviding)];
    NSDictionary<NSString *, id> *existingConfig = [remoteConfigService allValues];
    NSMutableDictionary<NSString *, id> *seedConfig = [[NSMutableDictionary alloc] init];

    if (existingConfig[@"home.headline"] == nil) {
        seedConfig[@"home.headline"] = @"Rapid App Bootstrap";
    }
    if (existingConfig[@"home.welcome.copy"] == nil) {
        seedConfig[@"home.welcome.copy"] = @"Home 模块负责展示路由、权限和 UI 基座，Account 模块负责账号与配置服务演示。";
    }
    if (existingConfig[@"feature.empty_state_demo"] == nil) {
        seedConfig[@"feature.empty_state_demo"] = @YES;
    }

    if (seedConfig.count > 0) {
        [remoteConfigService applyConfigDictionary:seedConfig];
    }

    [logger logWithLevel:OCBLogLevelInfo
                 message:[NSString stringWithFormat:@"Module Home bootstrapped with %lu seeded config keys.", (unsigned long)seedConfig.count]];
}

@end
