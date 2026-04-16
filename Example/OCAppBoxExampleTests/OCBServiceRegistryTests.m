#import <XCTest/XCTest.h>
#import <OCAppBox/OCAppBox.h>

@protocol OCBPrimaryTestService <NSObject>
@end

@protocol OCBSecondaryTestService <NSObject>
@end

@interface OCBPrimaryTestServiceImpl : NSObject <OCBPrimaryTestService>

+ (NSInteger)initCount;
+ (void)resetInitCount;

@end

@implementation OCBPrimaryTestServiceImpl

static NSInteger OCBPrimaryTestServiceImplInitCount = 0;

+ (NSInteger)initCount
{
    return OCBPrimaryTestServiceImplInitCount;
}

+ (void)resetInitCount
{
    OCBPrimaryTestServiceImplInitCount = 0;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        OCBPrimaryTestServiceImplInitCount += 1;
    }
    return self;
}

@end

@interface OCBSecondaryTestServiceImpl : NSObject <OCBSecondaryTestService>
@end

@implementation OCBSecondaryTestServiceImpl
@end

@interface OCBServiceRegistryTests : XCTestCase

@property (nonatomic, strong) OCBServiceRegistry *serviceRegistry;

@end

@implementation OCBServiceRegistryTests

- (void)setUp
{
    [super setUp];
    self.serviceRegistry = [[OCBServiceRegistry alloc] init];
    [OCBPrimaryTestServiceImpl resetInitCount];
}

- (void)tearDown
{
    self.serviceRegistry = nil;
    [super tearDown];
}

- (void)testRegisterServiceReturnsExactInstance
{
    OCBSecondaryTestServiceImpl *service = [[OCBSecondaryTestServiceImpl alloc] init];
    [self.serviceRegistry registerService:service forProtocol:@protocol(OCBSecondaryTestService)];

    id fetchedService = [self.serviceRegistry serviceForProtocol:@protocol(OCBSecondaryTestService)];

    XCTAssertTrue(fetchedService == service);
    XCTAssertEqualObjects(self.serviceRegistry.allRegisteredProtocolNames, (@[@"OCBSecondaryTestService"]));
    XCTAssertEqualObjects(self.serviceRegistry.allInstantiatedProtocolNames, (@[@"OCBSecondaryTestService"]));
}

- (void)testRegisterServiceClassInstantiatesOnlyOnce
{
    [self.serviceRegistry registerServiceClass:[OCBPrimaryTestServiceImpl class]
                                   forProtocol:@protocol(OCBPrimaryTestService)];

    id firstService = [self.serviceRegistry serviceForProtocol:@protocol(OCBPrimaryTestService)];
    id secondService = [self.serviceRegistry serviceForProtocol:@protocol(OCBPrimaryTestService)];

    XCTAssertNotNil(firstService);
    XCTAssertTrue(firstService == secondService);
    XCTAssertEqual([OCBPrimaryTestServiceImpl initCount], 1);
}

- (void)testProtocolNameListingsReflectRegisteredAndInstantiatedServices
{
    [self.serviceRegistry registerServiceClass:[OCBPrimaryTestServiceImpl class]
                                   forProtocol:@protocol(OCBPrimaryTestService)];
    [self.serviceRegistry registerService:[[OCBSecondaryTestServiceImpl alloc] init]
                              forProtocol:@protocol(OCBSecondaryTestService)];

    XCTAssertTrue([self.serviceRegistry containsServiceForProtocol:@protocol(OCBPrimaryTestService)]);
    XCTAssertTrue([self.serviceRegistry containsServiceForProtocol:@protocol(OCBSecondaryTestService)]);
    XCTAssertEqualObjects(self.serviceRegistry.allRegisteredProtocolNames,
                          (@[@"OCBPrimaryTestService", @"OCBSecondaryTestService"]));
    XCTAssertEqualObjects(self.serviceRegistry.allInstantiatedProtocolNames, (@[@"OCBSecondaryTestService"]));

    [self.serviceRegistry serviceForProtocol:@protocol(OCBPrimaryTestService)];

    XCTAssertEqualObjects(self.serviceRegistry.allInstantiatedProtocolNames,
                          (@[@"OCBPrimaryTestService", @"OCBSecondaryTestService"]));
}

@end
