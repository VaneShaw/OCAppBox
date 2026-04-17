#import <XCTest/XCTest.h>
#import <OCAppBox.h>

@protocol OCBModuleManagerMarkerService <NSObject>
@end

@interface OCBModuleManagerMarkerServiceImpl : NSObject <OCBModuleManagerMarkerService>
@end

@implementation OCBModuleManagerMarkerServiceImpl
@end

@interface OCBModuleManagerRouteFixtureViewController : UIViewController
@end

@implementation OCBModuleManagerRouteFixtureViewController
@end

static OCBAppContext *OCBModuleManagerRegisteredContext = nil;
static NSMutableArray<NSString *> *OCBModuleManagerExecutionLog = nil;
static NSDictionary *OCBModuleManagerReceivedLaunchOptions = nil;

@interface OCBModuleManagerAutoRegisterTestModule : NSObject <OCBModuleProtocol>
@end

@interface OCBModuleManagerLaunchTask : NSObject <OCBLaunchTask>

- (instancetype)initWithIdentifier:(NSString *)taskIdentifier
                             stage:(OCBLaunchStage)stage
                          priority:(NSInteger)priority;

@end

@interface OCBModuleManagerLaunchOrderTestModule : NSObject <OCBModuleProtocol>
@end

@implementation OCBModuleManagerAutoRegisterTestModule

- (NSString *)moduleName
{
    return @"test.module-manager.auto-register";
}

- (void)registerServicesWithServiceRegistry:(OCBServiceRegistry *)serviceRegistry
{
    [serviceRegistry registerService:[[OCBModuleManagerMarkerServiceImpl alloc] init]
                         forProtocol:@protocol(OCBModuleManagerMarkerService)];
}

- (void)registerRoutesWithRouter:(OCBRouter *)router
{
    [router registerRoute:@"ocb://test/module-manager"
                  factory:^UIViewController * _Nullable(NSDictionary * _Nullable params) {
        return [[OCBModuleManagerRouteFixtureViewController alloc] init];
    }];
}

- (void)moduleDidRegisterWithContext:(OCBAppContext *)appContext
{
    OCBModuleManagerRegisteredContext = appContext;
}

@end

@interface OCBModuleManagerLaunchTask ()

@property (nonatomic, copy) NSString *taskIdentifier;
@property (nonatomic, assign) OCBLaunchStage stage;
@property (nonatomic, assign) NSInteger priority;

@end

@implementation OCBModuleManagerLaunchTask

- (instancetype)initWithIdentifier:(NSString *)taskIdentifier
                             stage:(OCBLaunchStage)stage
                          priority:(NSInteger)priority
{
    self = [super init];
    if (self) {
        _taskIdentifier = [taskIdentifier copy];
        _stage = stage;
        _priority = priority;
    }
    return self;
}

- (void)performWithAppContext:(OCBAppContext *)appContext
                launchOptions:(NSDictionary *)launchOptions
{
    [OCBModuleManagerExecutionLog addObject:self.taskIdentifier];
    OCBModuleManagerReceivedLaunchOptions = [launchOptions copy];
}

@end

@implementation OCBModuleManagerLaunchOrderTestModule

- (NSString *)moduleName
{
    return @"test.module-manager.launch-order";
}

- (NSArray<id<OCBLaunchTask>> *)launchTasks
{
    return @[
        [[OCBModuleManagerLaunchTask alloc] initWithIdentifier:@"test.launch.ui"
                                                         stage:OCBLaunchStageUI
                                                      priority:10],
        [[OCBModuleManagerLaunchTask alloc] initWithIdentifier:@"test.launch.module.b"
                                                         stage:OCBLaunchStageModule
                                                      priority:999],
        [[OCBModuleManagerLaunchTask alloc] initWithIdentifier:@"test.launch.bootstrap"
                                                         stage:OCBLaunchStageBootstrap
                                                      priority:1],
        [[OCBModuleManagerLaunchTask alloc] initWithIdentifier:@"test.launch.module.a"
                                                         stage:OCBLaunchStageModule
                                                      priority:999]
    ];
}

@end

@interface OCBModuleManagerTests : XCTestCase
@end

@implementation OCBModuleManagerTests

+ (void)setUp
{
    [super setUp];
    OCBRegisterModuleClass([OCBModuleManagerAutoRegisterTestModule class]);
}

- (void)setUp
{
    [super setUp];
    OCBModuleManagerRegisteredContext = nil;
    OCBModuleManagerExecutionLog = [[NSMutableArray alloc] init];
    OCBModuleManagerReceivedLaunchOptions = nil;
}

- (void)tearDown
{
    OCBModuleManagerExecutionLog = nil;
    OCBModuleManagerReceivedLaunchOptions = nil;
    OCBModuleManagerRegisteredContext = nil;
    [super tearDown];
}

- (void)testAutoRegisterModulesRegistersRouteServiceAndContextOnce
{
    NSArray<Class> *registeredModuleClasses = OCBAllRegisteredModuleClasses();
    XCTAssertTrue([registeredModuleClasses containsObject:[OCBModuleManagerAutoRegisterTestModule class]]);

    OCBAppContext *appContext = [[OCBAppContext alloc] init];
    [appContext.moduleManager autoRegisterModules];
    [appContext.moduleManager autoRegisterModules];

    NSPredicate *modulePredicate = [NSPredicate predicateWithBlock:^BOOL(id<OCBModuleProtocol> module, NSDictionary<NSString *,id> *bindings) {
        return [module isKindOfClass:[OCBModuleManagerAutoRegisterTestModule class]];
    }];
    NSArray<id<OCBModuleProtocol>> *matchingModules = [appContext.moduleManager.modules filteredArrayUsingPredicate:modulePredicate];

    XCTAssertEqual(matchingModules.count, 1);
    XCTAssertTrue([appContext.serviceRegistry containsServiceForProtocol:@protocol(OCBModuleManagerMarkerService)]);
    XCTAssertNotNil([appContext.router viewControllerForRoute:@"ocb://test/module-manager" params:nil]);
    XCTAssertTrue(OCBModuleManagerRegisteredContext == appContext);
}

- (void)testStartWithLaunchOptionsSortsTasksByStagePriorityAndIdentifier
{
    NSDictionary *launchOptions = @{@"source": @"unit-test"};
    OCBAppContext *appContext = [[OCBAppContext alloc] initWithLaunchOptions:launchOptions];
    OCBModuleManager *moduleManager = [[OCBModuleManager alloc] initWithAppContext:appContext];

    [moduleManager registerModule:[[OCBModuleManagerLaunchOrderTestModule alloc] init]];
    [moduleManager startWithLaunchOptions:launchOptions];

    XCTAssertEqualObjects(OCBModuleManagerExecutionLog,
                          (@[
                              @"test.launch.bootstrap",
                              @"test.launch.module.a",
                              @"test.launch.module.b",
                              @"test.launch.ui"
                          ]));
    XCTAssertEqualObjects(OCBModuleManagerReceivedLaunchOptions, launchOptions);
}

@end
