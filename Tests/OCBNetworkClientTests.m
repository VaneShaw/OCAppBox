#import <XCTest/XCTest.h>
#import <OCAppBox.h>

@interface OCBNetworkClientTests : XCTestCase
@end

@implementation OCBNetworkClientTests

- (void)testRequestDefaultsUseJSONSerializers
{
    OCBRequest *request = [[OCBRequest alloc] initWithPath:@"/feed"
                                                    method:OCBHTTPMethodGET
                                                parameters:@{@"page": @1}
                                                   headers:nil
                                           timeoutInterval:0.0];

    XCTAssertTrue(request.requestIdentifier.length > 0);
    XCTAssertEqual(request.requestSerializerType, OCBRequestSerializerTypeJSON);
    XCTAssertEqual(request.responseSerializerType, OCBResponseSerializerTypeJSON);
    XCTAssertEqualWithAccuracy(request.timeoutInterval, 15.0, 0.001);
}

- (void)testRequestConvenienceFactoriesReduceBoilerplate
{
    OCBRequest *getRequest = [OCBRequest GET:@"/feed" parameters:@{@"page": @2}];
    OCBRequest *postRequest = [OCBRequest POST:@"/auth/login" parameters:@{@"mobile": @"13800000000"}];
    OCBRequest *formRequest = [OCBRequest formRequestWithPath:@"/auth/token"
                                                      method:OCBHTTPMethodPOST
                                                  parameters:@{@"code": @"123456"}
                                                     headers:@{@"X-Debug": @"1"}];

    XCTAssertEqual(getRequest.method, OCBHTTPMethodGET);
    XCTAssertEqualObjects(getRequest.parameters[@"page"], @2);
    XCTAssertEqual(postRequest.method, OCBHTTPMethodPOST);
    XCTAssertEqualObjects(postRequest.path, @"/auth/login");
    XCTAssertEqual(formRequest.requestSerializerType, OCBRequestSerializerTypeFormURLEncoded);
    XCTAssertEqual(formRequest.responseSerializerType, OCBResponseSerializerTypeJSON);
    XCTAssertEqualObjects(formRequest.headers[@"X-Debug"], @"1");
}

- (void)testNetworkClientSupportsEnvironmentBaseURLs
{
    OCBNetworkClient *client = [[OCBNetworkClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://fallback.example.com"]];
    [client setBaseURL:[NSURL URLWithString:@"https://dev.example.com"] forEnvironment:@"development"];
    [client setBaseURL:[NSURL URLWithString:@"https://staging.example.com"] forEnvironment:@"staging"];
    [client useEnvironment:@"staging"];

    XCTAssertEqualObjects(client.currentEnvironment, @"staging");
    XCTAssertEqualObjects([client baseURLForEnvironment:@"development"].absoluteString, @"https://dev.example.com");
    XCTAssertEqualObjects([client baseURLForEnvironment:@"staging"].absoluteString, @"https://staging.example.com");
    XCTAssertEqualObjects([client registeredEnvironments], (@[@"development", @"staging"]));
}

- (void)testAppContextEnvironmentSynchronizesToBuiltinNetworkClient
{
    OCBAppContext *appContext = [[OCBAppContext alloc] init];
    id<OCBNetworking> network = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBNetworking)];
    [network setBaseURL:[NSURL URLWithString:@"https://dev.example.com"] forEnvironment:@"development"];
    [network setBaseURL:[NSURL URLWithString:@"https://example.com"] forEnvironment:@"production"];

    appContext.environment = @"production";

    XCTAssertEqualObjects([network currentEnvironment], @"production");
    XCTAssertEqualObjects([network baseURLForEnvironment:[network currentEnvironment]].absoluteString, @"https://example.com");
}

@end
