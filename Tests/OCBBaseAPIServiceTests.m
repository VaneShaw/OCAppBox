#import <XCTest/XCTest.h>

#import <OCAppBox.h>

@interface OCBMockNetworkingService : NSObject <OCBNetworking>

@property (nonatomic, strong, nullable) OCBRequest *lastRequest;
@property (nonatomic, strong, nullable) OCBNetworkResponse *nextResponse;
@property (nonatomic, strong, nullable) NSError *nextError;
@property (nonatomic, copy) NSString *currentEnvironment;

@end

@implementation OCBMockNetworkingService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentEnvironment = @"development";
    }
    return self;
}

- (void)sendRequest:(OCBRequest *)request completion:(OCBNetworkCompletion)completion
{
    self.lastRequest = request;
    OCB_SAFE_BLOCK(completion, self.nextResponse, self.nextError);
}

- (void)setBaseURL:(nullable NSURL *)baseURL forEnvironment:(NSString *)environment
{
}

- (nullable NSURL *)baseURLForEnvironment:(NSString *)environment
{
    return nil;
}

- (NSArray<NSString *> *)registeredEnvironments
{
    return @[self.currentEnvironment ?: @"development"];
}

- (void)useEnvironment:(NSString *)environment
{
    self.currentEnvironment = environment.length > 0 ? [environment copy] : @"development";
}

@end

@interface OCBFeedAPIService : OCBBaseAPIService

- (void)fetchFeedWithCompletion:(OCBAPIServiceCompletion)completion;

@end

@implementation OCBFeedAPIService

- (void)fetchFeedWithCompletion:(OCBAPIServiceCompletion)completion
{
    [self GET:@"/feed" parameters:@{@"page": @1} completion:completion];
}

@end

@interface OCBWrappedFeedAPIService : OCBFeedAPIService
@end

@implementation OCBWrappedFeedAPIService

- (nullable id)responseDataForResponse:(nullable OCBNetworkResponse *)response
{
    NSArray *items = [response.businessData isKindOfClass:[NSArray class]] ? response.businessData : @[];
    return @{
        @"items": items,
        @"count": @(items.count)
    };
}

@end

@interface OCBBaseAPIServiceTests : XCTestCase

@property (nonatomic, strong) OCBAppContext *appContext;
@property (nonatomic, strong) OCBMockNetworkingService *networkingService;

@end

@implementation OCBBaseAPIServiceTests

- (void)setUp
{
    [super setUp];
    self.appContext = [[OCBAppContext alloc] init];
    self.networkingService = [[OCBMockNetworkingService alloc] init];
    [self.appContext.serviceRegistry registerService:self.networkingService forProtocol:@protocol(OCBNetworking)];
}

- (void)tearDown
{
    self.networkingService = nil;
    self.appContext = nil;
    [super tearDown];
}

- (void)testBaseAPIServiceUsesInjectedNetworkingAndReturnsBusinessData
{
    self.networkingService.nextResponse = [[OCBNetworkResponse alloc] initWithRequestIdentifier:@"request-1"
                                                                                     statusCode:200
                                                                                        headers:nil
                                                                                 responseObject:@{
        @"code": @0,
        @"message": @"ok",
        @"data": @[
            @"Home",
            @"Profile"
        ]
    }
                                                                                        rawData:nil];

    OCBFeedAPIService *service = [[OCBFeedAPIService alloc] initWithAppContext:self.appContext];
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetch feed"];

    [service fetchFeedWithCompletion:^(id  _Nullable data, OCBNetworkResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqualObjects(data, (@[@"Home", @"Profile"]));
        XCTAssertEqualObjects(response.businessMessage, @"ok");
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:1.0];
    XCTAssertEqualObjects(self.networkingService.lastRequest.path, @"/feed");
    XCTAssertEqual(self.networkingService.lastRequest.method, OCBHTTPMethodGET);
    XCTAssertEqualObjects(self.networkingService.lastRequest.parameters[@"page"], @1);
}

- (void)testBaseAPIServiceExposesBusinessErrorMessage
{
    self.networkingService.nextResponse = [[OCBNetworkResponse alloc] initWithRequestIdentifier:@"request-2"
                                                                                     statusCode:200
                                                                                        headers:nil
                                                                                 responseObject:@{
        @"code": @40101,
        @"message": @"Token expired"
    }
                                                                                        rawData:nil];
    self.networkingService.nextError = [OCBNetworkError businessErrorWithCode:@40101
                                                                      message:@"Token expired"
                                                               responseObject:@{
        @"code": @40101
    }
                                                                         data:nil];

    OCBFeedAPIService *service = (OCBFeedAPIService *)[OCBFeedAPIService serviceWithAppContext:self.appContext];
    XCTestExpectation *expectation = [self expectationWithDescription:@"business error"];

    [service fetchFeedWithCompletion:^(id  _Nullable data, OCBNetworkResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(data);
        XCTAssertEqual(error.code, OCBNetworkErrorCodeBusiness);
        XCTAssertEqualObjects([service messageForError:error defaultValue:@"fallback"], @"Token expired");
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testSubclassCanOverrideResponseDataTransformation
{
    self.networkingService.nextResponse = [[OCBNetworkResponse alloc] initWithRequestIdentifier:@"request-3"
                                                                                     statusCode:200
                                                                                        headers:nil
                                                                                 responseObject:@{
        @"code": @0,
        @"data": @[
            @"Home",
            @"Profile",
            @"Account"
        ]
    }
                                                                                        rawData:nil];

    OCBWrappedFeedAPIService *service = [[OCBWrappedFeedAPIService alloc] initWithAppContext:self.appContext];
    XCTestExpectation *expectation = [self expectationWithDescription:@"wrapped data"];

    [service fetchFeedWithCompletion:^(id  _Nullable data, OCBNetworkResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqualObjects(data, (@{
            @"items": @[@"Home", @"Profile", @"Account"],
            @"count": @3
        }));
        XCTAssertTrue(response.isBusinessSuccess);
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:1.0];
}

- (void)testBaseAPIServiceSupportsPaginationRequestHelper
{
    self.networkingService.nextResponse = [[OCBNetworkResponse alloc] initWithRequestIdentifier:@"request-4"
                                                                                     statusCode:200
                                                                                        headers:nil
                                                                                 responseObject:@{
        @"code": @0,
        @"data": @[]
    }
                                                                                        rawData:nil];
    OCBFeedAPIService *service = [[OCBFeedAPIService alloc] initWithAppContext:self.appContext];
    XCTestExpectation *expectation = [self expectationWithDescription:@"pagination request"];

    [service GET:@"/feed/list"
            page:2
        pageSize:20
      parameters:@{@"channel": @"all"}
      completion:^(id  _Nullable data, OCBNetworkResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:1.0];
    XCTAssertEqualObjects(self.networkingService.lastRequest.path, @"/feed/list");
    XCTAssertEqualObjects(self.networkingService.lastRequest.parameters[@"page"], @2);
    XCTAssertEqualObjects(self.networkingService.lastRequest.parameters[@"page_size"], @20);
    XCTAssertEqualObjects(self.networkingService.lastRequest.parameters[@"channel"], @"all");
}

@end
