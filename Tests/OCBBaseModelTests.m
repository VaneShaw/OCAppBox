#import <XCTest/XCTest.h>
#import <OCAppBox.h>

@interface OCBBaseModelTests : XCTestCase
@end

@implementation OCBBaseModelTests

- (void)testDictionaryRoundTripAndSecureCoding
{
    OCBBaseModel *model = [[OCBBaseModel alloc] initWithDictionary:@{@"id": @"abc"}];
    XCTAssertEqualObjects(model.modelIdentifier, @"abc");
    XCTAssertEqualObjects([model toDictionary][@"id"], @"abc");

    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model requiringSecureCoding:YES error:&error];
    XCTAssertNotNil(data, @"%@", error);

    OCBBaseModel *decoded = [NSKeyedUnarchiver unarchivedObjectOfClass:[OCBBaseModel class] fromData:data error:&error];
    XCTAssertNotNil(decoded, @"%@", error);
    XCTAssertEqualObjects(decoded.modelIdentifier, @"abc");
}

@end
