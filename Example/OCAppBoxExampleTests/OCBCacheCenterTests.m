#import <XCTest/XCTest.h>
#import <OCAppBox/OCAppBox.h>

@interface OCBCacheCenterTests : XCTestCase

@property (nonatomic, strong) OCBCacheCenter *cacheCenter;
@property (nonatomic, strong) NSMutableArray<NSString *> *usedKeys;

@end

@implementation OCBCacheCenterTests

- (void)setUp
{
    [super setUp];
    self.cacheCenter = [[OCBCacheCenter alloc] init];
    self.usedKeys = [[NSMutableArray alloc] init];
}

- (void)tearDown
{
    for (NSString *key in self.usedKeys) {
        [self.cacheCenter removeObjectForKey:key];
    }

    self.cacheCenter = nil;
    self.usedKeys = nil;
    [super tearDown];
}

- (void)testMemoryObjectRoundTrip
{
    NSString *key = [self uniqueKeyWithSuffix:@"memory"];
    NSDictionary *payload = @{@"value": @"cached"};

    [self.cacheCenter setMemoryObject:payload forKey:key];

    XCTAssertEqualObjects([self.cacheCenter memoryObjectForKey:key], payload);

    [self.cacheCenter removeObjectForKey:key];

    XCTAssertNil([self.cacheCenter memoryObjectForKey:key]);
}

- (void)testDiskObjectRoundTrip
{
    NSString *key = [self uniqueKeyWithSuffix:@"disk/test:value"];
    NSDictionary *payload = @{@"feature": @"enabled", @"title": @"OCAppBox"};

    [self.cacheCenter setDiskObject:payload forKey:key];

    XCTAssertEqualObjects([self.cacheCenter diskObjectForKey:key], payload);
}

- (void)testRemoveObjectClearsDiskObject
{
    NSString *key = [self uniqueKeyWithSuffix:@"remove/disk:value"];

    [self.cacheCenter setDiskObject:@[@"A", @"B"] forKey:key];
    XCTAssertNotNil([self.cacheCenter diskObjectForKey:key]);

    [self.cacheCenter removeObjectForKey:key];

    XCTAssertNil([self.cacheCenter diskObjectForKey:key]);
}

- (NSString *)uniqueKeyWithSuffix:(NSString *)suffix
{
    NSString *key = [NSString stringWithFormat:@"ocb.test.%@.%@", NSUUID.UUID.UUIDString, suffix];
    [self.usedKeys addObject:key];
    return key;
}

@end
