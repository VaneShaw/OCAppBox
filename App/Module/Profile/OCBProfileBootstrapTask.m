#import "OCBProfileBootstrapTask.h"

#import <Core/OCBAppContext.h>
#import <Core/OCBServiceRegistry.h>
#import <Infra/Log/OCBLogger.h>

@implementation OCBProfileBootstrapTask

- (NSString *)taskIdentifier
{
    return @"module.profile.bootstrap";
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
    [logger logWithLevel:OCBLogLevelInfo
                 message:[NSString stringWithFormat:@"Module Profile bootstrapped on route: ocb://profile"]];
}

@end
