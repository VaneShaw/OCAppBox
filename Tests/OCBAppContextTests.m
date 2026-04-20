#import <XCTest/XCTest.h>
#import <OCAppBox.h>

@protocol OCBAppContextExportedService <NSObject>

@property (nonatomic, weak, readonly) OCBAppContext *appContext;

@end

@interface OCBAppContextExportedServiceImpl : NSObject <OCBAppContextExportedService, OCBAppContextServiceFactory>

- (instancetype)initWithAppContext:(OCBAppContext *)appContext;

@end

@interface OCBAppContextExportedServiceImpl ()

@property (nonatomic, weak, readwrite) OCBAppContext *appContext;

@end

static NSInteger OCBAppContextExportedServiceFactoryCallCount = 0;

@implementation OCBAppContextExportedServiceImpl

- (instancetype)initWithAppContext:(OCBAppContext *)appContext
{
    self = [super init];
    if (self) {
        _appContext = appContext;
    }
    return self;
}

+ (id)serviceWithAppContext:(OCBAppContext *)appContext
{
    OCBAppContextExportedServiceFactoryCallCount += 1;
    return [[self alloc] initWithAppContext:appContext];
}

@end

@interface OCBAppContextTests : XCTestCase
@end

@implementation OCBAppContextTests

+ (void)setUp
{
    [super setUp];
    OCBRegisterServiceClass(@protocol(OCBAppContextExportedService), [OCBAppContextExportedServiceImpl class]);
}

- (void)setUp
{
    [super setUp];
    OCBAppContextExportedServiceFactoryCallCount = 0;
}

- (void)testInitRegistersBuiltinServices
{
    NSDictionary *launchOptions = @{@"launch": @"options"};
    OCBAppContext *appContext = [[OCBAppContext alloc] initWithLaunchOptions:launchOptions];

    XCTAssertEqualObjects(appContext.launchOptions, launchOptions);
    XCTAssertTrue([appContext.serviceRegistry containsServiceForProtocol:@protocol(OCBLogging)]);
    XCTAssertTrue([appContext.serviceRegistry containsServiceForProtocol:@protocol(OCBStorageProviding)]);
    XCTAssertTrue([appContext.serviceRegistry containsServiceForProtocol:@protocol(OCBNetworking)]);
    XCTAssertTrue([appContext.serviceRegistry containsServiceForProtocol:@protocol(OCBThemeProviding)]);
    XCTAssertTrue([appContext.serviceRegistry containsServiceForProtocol:@protocol(OCBUserSessionProviding)]);
    XCTAssertTrue([appContext.serviceRegistry containsServiceForProtocol:@protocol(OCBAuthenticating)]);
    XCTAssertTrue([appContext.serviceRegistry containsServiceForProtocol:@protocol(OCBPermissionProviding)]);
    XCTAssertTrue([appContext.serviceRegistry containsServiceForProtocol:@protocol(OCBRemoteConfigProviding)]);
    XCTAssertTrue([appContext.serviceRegistry containsServiceForProtocol:@protocol(OCBConfigProviding)]);
    XCTAssertTrue([appContext.serviceRegistry containsServiceForProtocol:@protocol(OCBKeychainStoring)]);
}

- (void)testInitRegistersExportedServiceUsingAppContextFactory
{
    NSDictionary<NSString *, Class> *registeredServiceClasses = OCBAllRegisteredServiceClasses();
    XCTAssertTrue(registeredServiceClasses[NSStringFromProtocol(@protocol(OCBAppContextExportedService))] == [OCBAppContextExportedServiceImpl class]);

    OCBAppContext *appContext = [[OCBAppContext alloc] init];
    id<OCBAppContextExportedService> service = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBAppContextExportedService)];

    XCTAssertNotNil(service);
    XCTAssertTrue(service.appContext == appContext);
    XCTAssertEqual(OCBAppContextExportedServiceFactoryCallCount, 1);
    XCTAssertTrue([appContext.serviceRegistry serviceForProtocol:@protocol(OCBAppContextExportedService)] == service);
}

@end
