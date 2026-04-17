#import <XCTest/XCTest.h>

#import "OCBStarterAppConfiguration.h"

@interface OCBStarterAppConfigurationTests : XCTestCase
@end

@implementation OCBStarterAppConfigurationTests

- (void)testStarterConfigurationProvidesExpectedTabs
{
    NSArray *tabs = [OCBStarterAppConfiguration starterTabs];

    XCTAssertEqualObjects([OCBStarterAppConfiguration defaultEnvironment], @"development");
    XCTAssertEqual(tabs.count, 3);
    XCTAssertEqualObjects([tabs valueForKey:@"title"], (@[@"Home", @"Profile", @"Account"]));
}

- (void)testStarterConfigurationProvidesEnvironmentBaseURLs
{
    XCTAssertEqualObjects([OCBStarterAppConfiguration baseURLForEnvironment:@"development"].absoluteString,
                          @"https://dev.example.com");
    XCTAssertEqualObjects([OCBStarterAppConfiguration baseURLForEnvironment:@"production"].absoluteString,
                          @"https://example.com");
    XCTAssertNil([OCBStarterAppConfiguration baseURLForEnvironment:@""]);
}

@end
