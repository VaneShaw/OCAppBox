#import "OCBDemoAppLauncher.h"

#import <OCAppBox.h>

#import "OCBStarterAppConfiguration.h"

@interface OCBDemoAppLauncher ()

@property (nonatomic, copy) NSDictionary *launchOptions;
@property (nonatomic, strong, readwrite) OCBAppContext *appContext;

- (NSArray<OCBTabBarItemDescriptor *> *)starterTabs;
- (void)prepareStarterEnvironment;

@end

@implementation OCBDemoAppLauncher

- (instancetype)initWithLaunchOptions:(NSDictionary *)launchOptions
{
    self = [super init];
    if (self) {
        _launchOptions = [launchOptions copy] ?: @{};
    }
    return self;
}

- (void)launchInWindow:(UIWindow *)window
{
    NSParameterAssert(window != nil);

    self.appContext = [[OCBAppContext alloc] initWithLaunchOptions:self.launchOptions];
    self.appContext.environment = [OCBStarterAppConfiguration defaultEnvironment];
    self.appContext.window = window;

    [self bootstrapAppContext];

    UIViewController *rootViewController = [self rootViewController];
    window.rootViewController = rootViewController;
    [window makeKeyAndVisible];
}

- (void)bootstrapAppContext
{
    id<OCBLogging> logger = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBLogging)];
    [logger logWithLevel:OCBLogLevelInfo message:@"Application did finish launching."];

    [self prepareStarterEnvironment];
    [self.appContext.moduleManager autoRegisterModules];
    [self.appContext.moduleManager startWithLaunchOptions:self.launchOptions];
}

- (UIViewController *)rootViewController
{
    return [[OCBTabBarController alloc] initWithAppContext:self.appContext tabDescriptors:[self starterTabs]];
}

- (NSArray<OCBTabBarItemDescriptor *> *)starterTabs
{
    return [OCBStarterAppConfiguration starterTabs];
}

- (void)prepareStarterEnvironment
{
    id<OCBLogging> logger = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBLogging)];
    id<OCBStorageProviding> storage = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBStorageProviding)];
    id<OCBNetworking> network = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBNetworking)];
    id<OCBMutablePermissionProviding> permissionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBMutablePermissionProviding)];
    id<OCBMutableRemoteConfigProviding> remoteConfigService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBMutableRemoteConfigProviding)];

    [storage setMemoryObject:self.appContext.environment forKey:@"app.environment"];
    [storage setDiskObject:[NSString stringWithFormat:@"boot:%@", [NSDate date]] forKey:@"app.lastLaunch"];
    [[OCBAPIResponseMapper sharedMapper] resetToDefaults];
    [OCBStarterAppConfiguration configureAPIResponseMapper:[OCBAPIResponseMapper sharedMapper]];
    [logger logWithLevel:OCBLogLevelInfo
                 message:[NSString stringWithFormat:@"Bootstrap in environment: %@", self.appContext.environment]];

    if ([network isKindOfClass:[OCBNetworkClient class]]) {
        OCBNetworkClient *networkClient = (OCBNetworkClient *)network;
        [[OCBStarterAppConfiguration networkBaseURLsByEnvironment] enumerateKeysAndObjectsUsingBlock:^(NSString *environment, NSURL *baseURL, BOOL *stop) {
            [networkClient setBaseURL:baseURL forEnvironment:environment];
        }];
        [networkClient useEnvironment:self.appContext.environment];
        networkClient.commonHeaders = [OCBStarterAppConfiguration networkCommonHeaders];
        [logger logWithLevel:OCBLogLevelDebug
                     message:[NSString stringWithFormat:@"Network environment %@ prepared with baseURL %@",
                              networkClient.currentEnvironment,
                              [networkClient baseURLForEnvironment:networkClient.currentEnvironment].absoluteString ?: networkClient.baseURL.absoluteString ?: @"-"]];
    }

    [permissionService updateStatus:OCBPermissionStatusUnknown forPermission:@"camera"];
    [remoteConfigService applyConfigDictionary:[OCBStarterAppConfiguration bootstrapRemoteConfig]];
}

@end
