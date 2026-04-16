#import "OCBDemoBootstrapTask.h"

@implementation OCBDemoBootstrapTask

- (NSString *)taskIdentifier
{
    return @"demo.bootstrap";
}

- (OCBLaunchStage)stage
{
    return OCBLaunchStageBootstrap;
}

- (NSInteger)priority
{
    return 100;
}

- (void)performWithAppContext:(OCBAppContext *)appContext
                launchOptions:(NSDictionary *)launchOptions
{
    id<OCBLogging> logger = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBLogging)];
    id<OCBStorageProviding> storage = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBStorageProviding)];
    id<OCBNetworking> network = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBNetworking)];
    id<OCBPermissionProviding> permissionService = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBPermissionProviding)];
    id<OCBRemoteConfigProviding> remoteConfigService = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBRemoteConfigProviding)];

    [storage setMemoryObject:appContext.environment forKey:@"demo.environment"];
    [storage setDiskObject:[NSString stringWithFormat:@"boot:%@", [NSDate date]] forKey:@"demo.lastLaunch"];
    [logger logWithLevel:OCBLogLevelInfo message:[NSString stringWithFormat:@"Bootstrap in environment: %@", appContext.environment]];

    if ([network isKindOfClass:[OCBNetworkClient class]]) {
        OCBNetworkClient *networkClient = (OCBNetworkClient *)network;
        networkClient.baseURL = [NSURL URLWithString:@"https://example.com"];
        [logger logWithLevel:OCBLogLevelDebug message:[NSString stringWithFormat:@"Network baseURL prepared: %@", networkClient.baseURL.absoluteString]];
    }

    [permissionService setMockStatus:OCBPermissionStatusUnknown forPermission:@"camera"];
    [remoteConfigService applyConfigDictionary:@{
        @"home.headline": @"Service Layer Ready",
        @"home.welcome.copy": @"UserSession、Auth、Permission、RemoteConfig 已接入 Demo 页面，可以直接作为业务公共服务入口。",
        @"feature.empty_state_demo": @YES
    }];
}

@end
