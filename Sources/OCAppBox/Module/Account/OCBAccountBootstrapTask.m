#import "OCBAccountBootstrapTask.h"

#import "OCBAppContext.h"
#import "OCBServiceRegistry.h"
#import "OCBLogger.h"
#import "OCBRemoteConfigService.h"

@implementation OCBAccountBootstrapTask

- (NSString *)taskIdentifier
{
    return @"module.account.bootstrap";
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
    id<OCBRemoteConfigProviding> remoteConfigService = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBRemoteConfigProviding)];
    NSDictionary<NSString *, id> *existingConfig = [remoteConfigService allValues];
    NSMutableDictionary<NSString *, id> *seedConfig = [[NSMutableDictionary alloc] init];

    if (existingConfig[@"account.headline"] == nil) {
        seedConfig[@"account.headline"] = @"Account Service Center";
    }
    if (existingConfig[@"account.summary"] == nil) {
        seedConfig[@"account.summary"] = @"这里演示 Auth、UserSession 和 RemoteConfig 的组合接入。";
    }
    if (existingConfig[@"account.refresh.version"] == nil) {
        seedConfig[@"account.refresh.version"] = @0;
    }

    if (seedConfig.count > 0) {
        [remoteConfigService applyConfigDictionary:seedConfig];
    }

    [logger logWithLevel:OCBLogLevelInfo
                 message:[NSString stringWithFormat:@"Module Account bootstrapped with %lu seeded config keys.", (unsigned long)seedConfig.count]];
}

@end
