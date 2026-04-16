#import "__APP_PREFIX__BootstrapTask.h"

@implementation __APP_PREFIX__BootstrapTask

- (NSString *)taskIdentifier
{
    return @"__APP_IDENTIFIER__.bootstrap";
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
    id<OCBMutablePermissionProviding> permissionService = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBMutablePermissionProviding)];
    id<OCBMutableRemoteConfigProviding> remoteConfigService = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBMutableRemoteConfigProviding)];

    [storage setMemoryObject:appContext.environment forKey:@"__APP_IDENTIFIER__.environment"];
    [storage setDiskObject:[NSString stringWithFormat:@"boot:%@", [NSDate date]]
                    forKey:@"__APP_IDENTIFIER__.lastLaunch"];
    [logger logWithLevel:OCBLogLevelInfo
                 message:[NSString stringWithFormat:@"%@ bootstrap in environment: %@",
                          @"__APP_DISPLAY_NAME__",
                          appContext.environment]];

    if ([network isKindOfClass:[OCBNetworkClient class]]) {
        OCBNetworkClient *networkClient = (OCBNetworkClient *)network;
        networkClient.baseURL = [NSURL URLWithString:@"https://example.com"];
        networkClient.commonHeaders = @{
            @"X-OCApp-Host": @"__APP_NAME__"
        };
    }

    [permissionService updateStatus:OCBPermissionStatusUnknown forPermission:@"camera"];
    [remoteConfigService applyConfigDictionary:@{
        @"host.headline": @"__APP_DISPLAY_NAME__ Host Ready",
        @"host.summary": @"宿主工程已经接入 OCAppBox，可以直接从这里继续拆业务模块和页面。",
        @"feature.empty_state_demo": @YES
    }];
}

@end
