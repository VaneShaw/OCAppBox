#import "AppDelegate.h"

#import "__APP_PREFIX__AppLauncher.h"

@interface AppDelegate ()

@property (nonatomic, strong) __APP_PREFIX__AppLauncher *appLauncher;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.appLauncher = [[__APP_PREFIX__AppLauncher alloc] initWithLaunchOptions:launchOptions];
    [self.appLauncher launchInWindow:self.window];
    return YES;
}

@end
