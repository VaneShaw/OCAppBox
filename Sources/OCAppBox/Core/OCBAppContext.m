#import "OCBAppContext.h"

#import "OCBAutoRegister.h"
#import "OCBCacheCenter.h"
#import "OCBAuthService.h"
#import "OCBLogger.h"
#import "OCBModuleManager.h"
#import "OCBNetworkClient.h"
#import "OCBPermissionService.h"
#import "OCBRemoteConfigService.h"
#import "OCBRouter.h"
#import "OCBServiceRegistry.h"
#import "OCBThemeManager.h"
#import "OCBUserSessionService.h"

@interface OCBAppContext ()

- (void)registerBuiltinServices;
- (void)registerExportedServices;

@end

@implementation OCBAppContext

- (instancetype)init
{
    return [self initWithLaunchOptions:nil];
}

- (instancetype)initWithLaunchOptions:(nullable NSDictionary *)launchOptions
{
    self = [super init];
    if (self) {
        _launchOptions = [launchOptions copy] ?: @{};
        _environment = @"development";
        _serviceRegistry = [[OCBServiceRegistry alloc] init];
        _router = [[OCBRouter alloc] init];
        [self registerBuiltinServices];
        [self registerExportedServices];
        _moduleManager = [[OCBModuleManager alloc] initWithAppContext:self];
    }
    return self;
}

- (void)registerBuiltinServices
{
    id<OCBLogging> logger = [OCBLogger sharedLogger];
    id<OCBStorageProviding> storage = [[OCBCacheCenter alloc] init];
    id<OCBNetworking> network = [[OCBNetworkClient alloc] initWithBaseURL:nil];
    id<OCBThemeProviding> theme = [OCBThemeManager sharedManager];
    id<OCBUserSessionProviding> sessionService = [[OCBUserSessionService alloc] initWithStorage:storage
                                                                                          logger:logger];
    id<OCBAuthenticating> authService = [[OCBAuthService alloc] initWithUserSessionService:sessionService
                                                                                     logger:logger];
    id<OCBMutablePermissionProviding> permissionService = [[OCBPermissionService alloc] initWithStorage:storage
                                                                                                   logger:logger];
    id<OCBMutableRemoteConfigProviding> remoteConfigService = [[OCBRemoteConfigService alloc] initWithStorage:storage
                                                                                                           logger:logger];

    [self.serviceRegistry registerService:logger forProtocol:@protocol(OCBLogging)];
    [self.serviceRegistry registerService:storage forProtocol:@protocol(OCBStorageProviding)];
    [self.serviceRegistry registerService:network forProtocol:@protocol(OCBNetworking)];
    [self.serviceRegistry registerService:theme forProtocol:@protocol(OCBThemeProviding)];
    [self.serviceRegistry registerService:sessionService forProtocol:@protocol(OCBUserSessionProviding)];
    [self.serviceRegistry registerService:authService forProtocol:@protocol(OCBAuthenticating)];
    [self.serviceRegistry registerService:permissionService forProtocol:@protocol(OCBPermissionProviding)];
    [self.serviceRegistry registerService:permissionService forProtocol:@protocol(OCBMutablePermissionProviding)];
    [self.serviceRegistry registerService:remoteConfigService forProtocol:@protocol(OCBRemoteConfigProviding)];
    [self.serviceRegistry registerService:remoteConfigService forProtocol:@protocol(OCBMutableRemoteConfigProviding)];
}

- (void)registerExportedServices
{
    NSDictionary<NSString *, Class> *serviceClasses = OCBAllRegisteredServiceClasses();
    [serviceClasses enumerateKeysAndObjectsUsingBlock:^(NSString *protocolName, Class serviceClass, BOOL *stop) {
        Protocol *serviceProtocol = NSProtocolFromString(protocolName);
        if (serviceProtocol == nil || [self.serviceRegistry containsServiceForProtocol:serviceProtocol]) {
            return;
        }

        id service = nil;
        if ([serviceClass respondsToSelector:@selector(serviceWithAppContext:)]) {
            service = [(id<OCBAppContextServiceFactory>)serviceClass serviceWithAppContext:self];
        } else {
            service = [[serviceClass alloc] init];
        }

        if (service == nil) {
            return;
        }

        [self.serviceRegistry registerService:service forProtocol:serviceProtocol];
    }];
}

@end
