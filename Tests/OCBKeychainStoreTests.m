#import <XCTest/XCTest.h>
#import <OCAppBox.h>

@interface OCBKeychainStoreTests : XCTestCase
@end

@implementation OCBKeychainStoreTests

- (void)testKeychainServiceResolvableFromRegistry
{
    OCBAppContext *context = [[OCBAppContext alloc] init];
    id<OCBKeychainStoring> keychain = [context.serviceRegistry serviceForProtocol:@protocol(OCBKeychainStoring)];
    XCTAssertNotNil(keychain);
    XCTAssertTrue([keychain isKindOfClass:[OCBKeychainStore class]]);
}

@end
