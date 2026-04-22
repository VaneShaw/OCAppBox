#import <XCTest/XCTest.h>
#import <OCAppBox.h>

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

- (void)testViewAdditionsSupportFrameHelpersAndSubviewCleanup
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 20.0, 100.0, 200.0)];
    UIView *childView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];

    containerView.ocb_x = 16.0;
    containerView.ocb_y = 28.0;
    containerView.ocb_width = 120.0;
    containerView.ocb_height = 180.0;

    XCTAssertEqualWithAccuracy(containerView.ocb_x, 16.0, 0.001);
    XCTAssertEqualWithAccuracy(containerView.ocb_y, 28.0, 0.001);
    XCTAssertEqualWithAccuracy(containerView.ocb_width, 120.0, 0.001);
    XCTAssertEqualWithAccuracy(containerView.ocb_height, 180.0, 0.001);
    XCTAssertEqualWithAccuracy(containerView.ocb_maxX, 136.0, 0.001);
    XCTAssertEqualWithAccuracy(containerView.ocb_maxY, 208.0, 0.001);
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(containerView.ocb_safeAreaInsetsCompatible, UIEdgeInsetsZero));

    [containerView addSubview:childView];
    XCTAssertEqual(containerView.subviews.count, 1);
    [containerView ocb_removeAllSubviews];
    XCTAssertEqual(containerView.subviews.count, 0);
}

- (void)testDictionaryAdditionsSupportNestedKeyPathReads
{
    NSDictionary *payload = @{
        @"meta": @{
            @"code": @200,
            @"success": @"true"
        },
        @"payload": @{
            @"user": @{
                @"name": @"OCAppBox"
            },
            @"tabs": @[
                @"Home",
                @"Profile"
            ]
        }
    };

    XCTAssertEqualObjects([payload ocb_objectForKeyPath:@"meta.code"], @200);
    XCTAssertEqualObjects([payload ocb_stringForKeyPath:@"payload.user.name" defaultValue:nil], @"OCAppBox");
    XCTAssertTrue([payload ocb_boolForKeyPath:@"meta.success" defaultValue:NO]);
    XCTAssertEqual([payload ocb_integerForKeyPath:@"meta.code" defaultValue:0], 200);
    XCTAssertEqualWithAccuracy([payload ocb_doubleForKeyPath:@"meta.code" defaultValue:0], 200.0, 0.0001);
    XCTAssertEqualObjects([payload ocb_dictionaryForKeyPath:@"payload.user"], (@{@"name": @"OCAppBox"}));
    XCTAssertEqualObjects([payload ocb_arrayForKeyPath:@"payload.tabs"], (@[@"Home", @"Profile"]));
    XCTAssertNil([payload ocb_objectForKeyPath:@"payload.missing.value"]);
}

- (void)testStringAndImageAdditionsSupportURLAndRenderingHelpers
{
    NSString *rawPath = @"home/list?page=1&name=OC AppBox";
    NSString *encodedPath = [rawPath ocb_urlEncodedString];
    XCTAssertTrue([encodedPath containsString:@"%20"]);
    XCTAssertNotNil([@"{\"name\":\"OCAppBox\"}" ocb_JSONDictionaryObject]);
    XCTAssertNil([@"not-json" ocb_JSONDictionaryObject]);

    UIImage *solidImage = [UIImage ocb_imageWithColor:[UIColor redColor] size:CGSizeMake(8.0, 8.0)];
    XCTAssertEqualWithAccuracy(solidImage.size.width, 8.0, 0.001);
    XCTAssertEqualWithAccuracy(solidImage.size.height, 8.0, 0.001);

    UIImage *resizedImage = [solidImage ocb_resizedImageWithSize:CGSizeMake(20.0, 12.0)];
    XCTAssertEqualWithAccuracy(resizedImage.size.width, 20.0, 0.001);
    XCTAssertEqualWithAccuracy(resizedImage.size.height, 12.0, 0.001);
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
