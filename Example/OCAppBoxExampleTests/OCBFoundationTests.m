#import <XCTest/XCTest.h>
#import <OCAppBox/OCAppBox.h>

@interface OCBFoundationTests : XCTestCase
@end

@implementation OCBFoundationTests

- (void)testFoundationMacrosProvideExpectedRuntimeValues
{
    XCTAssertEqual(OCB_CLAMP(-2, 0, 10), 0);
    XCTAssertEqual(OCB_CLAMP(18, 0, 10), 10);
    XCTAssertEqual(OCB_CLAMP(6, 0, 10), 6);

    XCTAssertEqualWithAccuracy(OCB_DEGREES_TO_RADIANS(180.0), M_PI, 0.0001);
    XCTAssertEqualWithAccuracy(OCB_RADIANS_TO_DEGREES(M_PI_2), 90.0, 0.0001);

    NSString *title = @"OCAppBox";
    XCTAssertEqualObjects(OCB_SAFE_CAST(title, NSString), title);
    XCTAssertNil(OCB_SAFE_CAST(@42, NSString));

    XCTAssertGreaterThan(OCB_SCREEN_WIDTH, 0.0);
    XCTAssertGreaterThan(OCB_SCREEN_HEIGHT, 0.0);
    XCTAssertGreaterThan(OCB_ONE_PIXEL, 0.0);
}

- (void)testArrayAdditionsSafelyReadTypedValues
{
    NSArray *payload = @[
        @"title",
        @{@"enabled": @YES},
        @[@"nested"],
        [NSNull null]
    ];

    XCTAssertEqualObjects([payload ocb_objectAtIndexSafely:0], @"title");
    XCTAssertNil([payload ocb_objectAtIndexSafely:4]);
    XCTAssertNil([payload ocb_objectAtIndexSafely:3]);

    XCTAssertEqualObjects([payload ocb_stringAtIndex:0 defaultValue:nil], @"title");
    XCTAssertEqualObjects([payload ocb_stringAtIndex:3 defaultValue:@"fallback"], @"fallback");
    XCTAssertEqualObjects([payload ocb_dictionaryAtIndex:1], (@{@"enabled": @YES}));
    XCTAssertEqualObjects([payload ocb_arrayAtIndex:2], (@[@"nested"]));
    XCTAssertNil([payload ocb_dictionaryAtIndex:2]);
}

- (void)testColorAdditionsSupportHexValueAndHexString
{
    UIColor *valueColor = [UIColor ocb_colorWithHexValue:0x1452AB];
    [self assertColor:valueColor
                  red:(20.0 / 255.0)
                green:(82.0 / 255.0)
                 blue:(171.0 / 255.0)
                alpha:1.0];

    UIColor *hexStringColor = [UIColor ocb_colorWithHexString:@"#F5F"];
    [self assertColor:hexStringColor
                  red:1.0
                green:(85.0 / 255.0)
                 blue:1.0
                alpha:1.0];

    UIColor *hexStringWithAlphaColor = [UIColor ocb_colorWithHexString:@"80112233"];
    [self assertColor:hexStringWithAlphaColor
                  red:(17.0 / 255.0)
                green:(34.0 / 255.0)
                 blue:(51.0 / 255.0)
                alpha:(128.0 / 255.0)];

    UIColor *tintedColor = [UIColor ocb_colorWithHexString:@"#1452AB" alpha:0.5];
    [self assertColor:tintedColor
                  red:(20.0 / 255.0)
                green:(82.0 / 255.0)
                 blue:(171.0 / 255.0)
                alpha:0.5];

    XCTAssertNil([UIColor ocb_colorWithHexString:@"invalid"]);
}

- (void)assertColor:(UIColor *)color
                red:(CGFloat)red
              green:(CGFloat)green
               blue:(CGFloat)blue
              alpha:(CGFloat)alpha
{
    CGFloat actualRed = 0.0;
    CGFloat actualGreen = 0.0;
    CGFloat actualBlue = 0.0;
    CGFloat actualAlpha = 0.0;
    XCTAssertTrue([color getRed:&actualRed green:&actualGreen blue:&actualBlue alpha:&actualAlpha]);
    XCTAssertEqualWithAccuracy(actualRed, red, 0.0001);
    XCTAssertEqualWithAccuracy(actualGreen, green, 0.0001);
    XCTAssertEqualWithAccuracy(actualBlue, blue, 0.0001);
    XCTAssertEqualWithAccuracy(actualAlpha, alpha, 0.0001);
}

@end
