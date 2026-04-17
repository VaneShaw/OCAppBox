#import "OCB__MODULE_NAME__BootstrapTask.h"

#import <Core/OCBAppContext.h>
#import <Core/OCBServiceRegistry.h>
#import <Infra/Log/OCBLogger.h>

@implementation OCB__MODULE_NAME__BootstrapTask

- (NSString *)taskIdentifier
{
    return @"module.__MODULE_IDENTIFIER__.bootstrap";
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
                 message:[NSString stringWithFormat:@"Module __MODULE_NAME__ bootstrapped on route: __ROUTE_PATH__"]];
}

@end
