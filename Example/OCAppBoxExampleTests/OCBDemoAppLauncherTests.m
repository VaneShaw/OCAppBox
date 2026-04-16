#import <XCTest/XCTest.h>

#import "OCBDemoHomeViewController.h"
#import "OCBDemoAppLauncher.h"
#import "OCBDemoRouteCatalog.h"

#import <OCAppBox/OCAppBox.h>

@interface OCBDemoAppLauncherTests : XCTestCase
@end

@implementation OCBDemoAppLauncherTests

- (void)testLaunchInstallsExampleHostAsRootViewController
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0.0, 0.0, 390.0, 844.0)];
    NSDictionary *launchOptions = @{@"source": @"unit-test"};
    OCBDemoAppLauncher *launcher = [[OCBDemoAppLauncher alloc] initWithLaunchOptions:launchOptions];

    [launcher launchInWindow:window];

    XCTAssertNotNil(launcher.appContext);
    XCTAssertEqualObjects(launcher.appContext.launchOptions, launchOptions);
    XCTAssertTrue(launcher.appContext.window == window);
    XCTAssertTrue([window.rootViewController isKindOfClass:[OCBNavController class]]);

    OCBNavController *navigationController = (OCBNavController *)window.rootViewController;
    XCTAssertTrue([navigationController.topViewController isKindOfClass:[OCBDemoHomeViewController class]]);
}

- (void)testExampleRootRouteDoesNotOverrideFrameworkHomeRoute
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0.0, 0.0, 390.0, 844.0)];
    OCBDemoAppLauncher *launcher = [[OCBDemoAppLauncher alloc] initWithLaunchOptions:nil];

    [launcher launchInWindow:window];

    UIViewController *exampleRootViewController = [launcher.appContext.router viewControllerForRoute:OCBDemoRouteRoot params:nil];
    UIViewController *frameworkHomeViewController = [launcher.appContext.router viewControllerForRoute:OCBDemoRouteFrameworkHome params:nil];
    UIViewController *accountViewController = [launcher.appContext.router viewControllerForRoute:OCBDemoRouteAccount params:nil];
    UIViewController *debugViewController = [launcher.appContext.router viewControllerForRoute:OCBDemoRouteDebugPanel params:nil];

    XCTAssertTrue([exampleRootViewController isKindOfClass:[OCBDemoHomeViewController class]]);
    XCTAssertFalse([frameworkHomeViewController isKindOfClass:[OCBDemoHomeViewController class]]);
    XCTAssertNotNil(accountViewController);
    XCTAssertNotNil(debugViewController);
}

@end
