#import "__APP_PREFIX__AppLauncher.h"

#import <OCAppBox/OCAppBox.h>

#import "__APP_PREFIX__RouteCatalog.h"

@interface __APP_PREFIX__AppLauncher ()

@property (nonatomic, copy) NSDictionary *launchOptions;
@property (nonatomic, strong, readwrite) OCBAppContext *appContext;

@end

@implementation __APP_PREFIX__AppLauncher

- (instancetype)initWithLaunchOptions:(NSDictionary *)launchOptions
{
    self = [super init];
    if (self) {
        _launchOptions = [launchOptions copy] ?: @{};
        _rootRoutePath = [__APP_PREFIX__RouteRoot copy];
    }
    return self;
}

- (void)launchInWindow:(UIWindow *)window
{
    NSParameterAssert(window != nil);

    self.appContext = [[OCBAppContext alloc] initWithLaunchOptions:self.launchOptions];
    self.appContext.window = window;

    [self bootstrapAppContext];

    UIViewController *rootViewController = [self rootViewController];
    window.rootViewController = [[OCBNavController alloc] initWithRootViewController:rootViewController];
    [window makeKeyAndVisible];
}

- (void)bootstrapAppContext
{
    id<OCBLogging> logger = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBLogging)];
    [logger logWithLevel:OCBLogLevelInfo
                 message:[NSString stringWithFormat:@"%@ did finish launching.", @"__APP_DISPLAY_NAME__"]];

    [self.appContext.moduleManager autoRegisterModules];
    [self.appContext.moduleManager startWithLaunchOptions:self.launchOptions];
}

- (UIViewController *)rootViewController
{
    NSString *routePath = self.rootRoutePath.length > 0 ? self.rootRoutePath : __APP_PREFIX__RouteRoot;
    UIViewController *rootViewController = [self.appContext.router viewControllerForRoute:routePath params:nil];
    if (rootViewController != nil) {
        return rootViewController;
    }

    id<OCBLogging> logger = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBLogging)];
    [logger logWithLevel:OCBLogLevelError
                 message:[NSString stringWithFormat:@"Root route missing: %@", routePath]];

    UIViewController *fallbackViewController = [[UIViewController alloc] init];
    fallbackViewController.title = @"__APP_DISPLAY_NAME__";
    fallbackViewController.view.backgroundColor = [OCBThemeManager sharedManager].backgroundColor;

    UILabel *label = [[UILabel alloc] initWithFrame:fallbackViewController.view.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [OCBThemeManager sharedManager].primaryTextColor;
    label.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium];
    label.text = [NSString stringWithFormat:@"Missing root route:\n%@", routePath];
    [fallbackViewController.view addSubview:label];

    return fallbackViewController;
}

@end
