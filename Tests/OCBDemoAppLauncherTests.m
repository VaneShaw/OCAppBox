#import <XCTest/XCTest.h>

#import "OCBDemoAppLauncher.h"
#import "OCBDemoRouteCatalog.h"
#import "OCBStarterAppConfiguration.h"

#import <OCAppBox.h>

@interface OCBDemoAppLauncherTests : XCTestCase
@end

@implementation OCBDemoAppLauncherTests

- (void)testLaunchInstallsStarterHostAsRootViewController
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0.0, 0.0, 390.0, 844.0)];
    NSDictionary *launchOptions = @{@"source": @"unit-test"};
    OCBDemoAppLauncher *launcher = [[OCBDemoAppLauncher alloc] initWithLaunchOptions:launchOptions];

    [launcher launchInWindow:window];

    XCTAssertNotNil(launcher.appContext);
    XCTAssertEqualObjects(launcher.appContext.launchOptions, launchOptions);
    XCTAssertTrue(launcher.appContext.window == window);
    XCTAssertTrue([window.rootViewController isKindOfClass:[OCBTabBarController class]]);
    XCTAssertEqualObjects(launcher.appContext.environment, [OCBStarterAppConfiguration defaultEnvironment]);

    OCBTabBarController *tabBarController = (OCBTabBarController *)window.rootViewController;
    NSArray<OCBTabBarItemDescriptor *> *starterTabs = [OCBStarterAppConfiguration starterTabs];
    XCTAssertEqual(tabBarController.viewControllers.count, starterTabs.count);

    NSArray<NSString *> *titles = [tabBarController.viewControllers valueForKeyPath:@"tabBarItem.title"];
    XCTAssertEqualObjects(titles, [starterTabs valueForKey:@"title"]);
}

- (void)testStarterRoutesAreRegistered
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0.0, 0.0, 390.0, 844.0)];
    OCBDemoAppLauncher *launcher = [[OCBDemoAppLauncher alloc] initWithLaunchOptions:nil];

    [launcher launchInWindow:window];

    UIViewController *homeViewController = [launcher.appContext.router viewControllerForRoute:OCBDemoRouteHome params:nil];
    UIViewController *profileViewController = [launcher.appContext.router viewControllerForRoute:OCBDemoRouteProfile params:nil];
    UIViewController *accountViewController = [launcher.appContext.router viewControllerForRoute:OCBDemoRouteAccount params:nil];
    UIViewController *debugViewController = [launcher.appContext.router viewControllerForRoute:OCBDemoRouteDebugPanel params:nil];

    XCTAssertNotNil(homeViewController);
    XCTAssertNotNil(profileViewController);
    XCTAssertNotNil(accountViewController);
    XCTAssertNotNil(debugViewController);
}

@end
