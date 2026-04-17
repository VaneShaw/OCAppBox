#import <XCTest/XCTest.h>
#import <OCAppBox.h>

@interface OCBNetworkResponseTests : XCTestCase
@end

@implementation OCBNetworkResponseTests

- (void)setUp
{
    [super setUp];
    [[OCBAPIResponseMapper sharedMapper] resetToDefaults];
}

- (void)tearDown
{
    [[OCBAPIResponseMapper sharedMapper] resetToDefaults];
    [super tearDown];
}

- (void)testResponseParsesDefaultBusinessEnvelope
{
    OCBNetworkResponse *response = [[OCBNetworkResponse alloc] initWithRequestIdentifier:@"request-1"
                                                                              statusCode:200
                                                                                 headers:nil
                                                                          responseObject:@{
        @"code": @0,
        @"message": @"OK",
        @"data": @{
            @"userId": @"10001"
        }
    }
                                                                                 rawData:nil];

    XCTAssertTrue(response.isSuccess);
    XCTAssertTrue(response.hasBusinessEnvelope);
    XCTAssertTrue(response.isBusinessSuccess);
    XCTAssertEqualObjects(response.businessCode, @0);
    XCTAssertEqualObjects(response.businessMessage, @"OK");
    XCTAssertEqualObjects(response.businessData, (@{@"userId": @"10001"}));
}

- (void)testResponseSupportsNestedBusinessEnvelopeConfiguration
{
    OCBAPIResponseMapper *mapper = [OCBAPIResponseMapper sharedMapper];
    mapper.codeKeyPath = @"meta.code";
    mapper.messageKeyPath = @"meta.message";
    mapper.dataKeyPath = @"payload.result";
    mapper.successKeyPath = @"meta.success";
    mapper.successCodes = @[@10000];

    OCBNetworkResponse *response = [[OCBNetworkResponse alloc] initWithRequestIdentifier:@"request-2"
                                                                              statusCode:200
                                                                                 headers:nil
                                                                          responseObject:@{
        @"meta": @{
            @"code": @10000,
            @"message": @"done",
            @"success": @YES
        },
        @"payload": @{
            @"result": @[
                @"a",
                @"b"
            ]
        }
    }
                                                                                 rawData:nil];

    XCTAssertTrue(response.hasBusinessEnvelope);
    XCTAssertTrue(response.isBusinessSuccess);
    XCTAssertEqualObjects(response.businessCode, @10000);
    XCTAssertEqualObjects(response.businessMessage, @"done");
    XCTAssertEqualObjects(response.businessData, (@[@"a", @"b"]));
}

- (void)testResponseTreatsRawPayloadAsSuccessfulWithoutEnvelope
{
    OCBNetworkResponse *response = [[OCBNetworkResponse alloc] initWithRequestIdentifier:@"request-3"
                                                                              statusCode:200
                                                                                 headers:nil
                                                                          responseObject:@[
        @"feed",
        @"profile"
    ]
                                                                                 rawData:nil];

    XCTAssertFalse(response.hasBusinessEnvelope);
    XCTAssertTrue(response.isBusinessSuccess);
    XCTAssertEqualObjects(response.businessData, (@[@"feed", @"profile"]));
}

- (void)testBusinessErrorCapturesCodeMessageAndPayload
{
    NSError *error = [OCBNetworkError businessErrorWithCode:@40101
                                                    message:@"Token expired"
                                             responseObject:@{@"code": @40101}
                                                       data:@{@"reauth": @YES}];

    XCTAssertEqual(error.code, OCBNetworkErrorCodeBusiness);
    XCTAssertEqualObjects(error.localizedDescription, @"Token expired");
    XCTAssertEqualObjects(error.userInfo[OCBNetworkErrorBusinessCodeUserInfoKey], @40101);
    XCTAssertEqualObjects(error.userInfo[OCBNetworkErrorBusinessMessageUserInfoKey], @"Token expired");
    XCTAssertEqualObjects(error.userInfo[OCBNetworkErrorBusinessDataUserInfoKey], (@{@"reauth": @YES}));
}

@end
