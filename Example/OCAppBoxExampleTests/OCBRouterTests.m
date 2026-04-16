#import <XCTest/XCTest.h>
#import <OCAppBox/OCAppBox.h>

@interface OCBRouterFixtureViewController : UIViewController

@property (nonatomic, copy, readonly) NSDictionary *receivedParams;

- (instancetype)initWithParams:(NSDictionary *)params;

@end

@implementation OCBRouterFixtureViewController

- (instancetype)initWithParams:(NSDictionary *)params
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _receivedParams = [params copy];
    }
    return self;
}

@end

@interface OCBRouterTests : XCTestCase

@property (nonatomic, strong) OCBRouter *router;

@end

@implementation OCBRouterTests

- (void)setUp
{
    [super setUp];
    self.router = [[OCBRouter alloc] init];
}

- (void)tearDown
{
    self.router = nil;
    [super tearDown];
}

- (void)testRegisterRouteCreatesViewControllerWithPassedParams
{
    NSDictionary *params = @{@"title": @"Home"};
    [self.router registerRoute:@"ocb://test/home"
                       factory:^UIViewController * _Nullable(NSDictionary * _Nullable routeParams) {
        return [[OCBRouterFixtureViewController alloc] initWithParams:routeParams ?: @{}];
    }];

    OCBRouterFixtureViewController *viewController = (OCBRouterFixtureViewController *)[self.router viewControllerForRoute:@"ocb://test/home"
                                                                                                                      params:params];

    XCTAssertNotNil(viewController);
    XCTAssertEqualObjects(viewController.receivedParams, params);
}

- (void)testOpenRoutePushesOnNavigationController
{
    [self.router registerRoute:@"ocb://test/detail"
                       factory:^UIViewController * _Nullable(NSDictionary * _Nullable routeParams) {
        return [[UIViewController alloc] init];
    }];

    UIViewController *rootViewController = [[UIViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];

    BOOL didOpen = [self.router openRoute:@"ocb://test/detail"
                                   params:nil
                                     from:rootViewController
                                 animated:NO];

    XCTAssertTrue(didOpen);
    XCTAssertEqual(navigationController.viewControllers.count, 2);
    XCTAssertTrue([navigationController.topViewController isKindOfClass:[UIViewController class]]);
}

- (void)testAllRoutesAreSortedAndIgnoreInvalidRegistrations
{
    OCBRouteFactory routeFactory = ^UIViewController * _Nullable(NSDictionary * _Nullable routeParams) {
        return [[UIViewController alloc] init];
    };

    [self.router registerRoute:@"ocb://b" factory:routeFactory];
    [self.router registerRoute:@"" factory:routeFactory];
    [self.router registerRoute:@"ocb://a" factory:routeFactory];

    XCTAssertEqualObjects(self.router.allRoutes, (@[@"ocb://a", @"ocb://b"]));
}

@end
