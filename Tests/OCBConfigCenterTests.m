#import <XCTest/XCTest.h>
#import <OCAppBox.h>

@interface OCBConfigCenterTests : XCTestCase
@end

@implementation OCBConfigCenterTests

- (void)testRoundTripTypedValues
{
    OCBConfigCenter *center = [[OCBConfigCenter alloc] init];
    NSString *key = [NSString stringWithFormat:@"unit.test.%@", [[NSUUID UUID] UUIDString]];

    [center setObject:@"hello" forKey:key];
    XCTAssertEqualObjects([center stringForKey:key defaultValue:nil], @"hello");
    XCTAssertEqual([center integerForKey:key defaultValue:0], 0);

    [center setObject:@42 forKey:key];
    XCTAssertEqual([center integerForKey:key defaultValue:0], 42);

    [center setObject:@YES forKey:key];
    XCTAssertTrue([center boolForKey:key defaultValue:NO]);

    [center removeObjectForKey:key];
    XCTAssertNil([center objectForKey:key]);
}

@end
