#import "AppDelegate.h"

#import "OCBDemoAppLauncher.h"

@interface AppDelegate ()

@property (nonatomic, strong) OCBDemoAppLauncher *appLauncher;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.appLauncher = [[OCBDemoAppLauncher alloc] initWithLaunchOptions:launchOptions];
    [self.appLauncher launchInWindow:self.window];
    return YES;
}

@end
