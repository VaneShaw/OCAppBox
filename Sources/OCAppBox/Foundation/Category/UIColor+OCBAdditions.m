#import "UIColor+OCBAdditions.h"

#import "OCBFoundationMacros.h"
#import "NSString+OCBAdditions.h"

static BOOL OCBHexStringToRGBAComponents(NSString *hexString, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha)
{
    NSString *normalizedString = [[[hexString ocb_trimmedString] uppercaseString] copy];
    if (normalizedString.length == 0) {
        return NO;
    }

    if ([normalizedString hasPrefix:@"#"]) {
        normalizedString = [normalizedString substringFromIndex:1];
    } else if ([normalizedString hasPrefix:@"0X"]) {
        normalizedString = [normalizedString substringFromIndex:2];
    }

    if (normalizedString.length == 3) {
        unichar r = [normalizedString characterAtIndex:0];
        unichar g = [normalizedString characterAtIndex:1];
        unichar b = [normalizedString characterAtIndex:2];
        normalizedString = [NSString stringWithFormat:@"%C%C%C%C%C%C", r, r, g, g, b, b];
    }

    unsigned int hexValue = 0;
    if (![[NSScanner scannerWithString:normalizedString] scanHexInt:&hexValue]) {
        return NO;
    }

    switch (normalizedString.length) {
        case 6:
            *red = ((hexValue >> 16) & 0xFF) / 255.0;
            *green = ((hexValue >> 8) & 0xFF) / 255.0;
            *blue = (hexValue & 0xFF) / 255.0;
            *alpha = 1.0;
            return YES;
        case 8:
            *alpha = ((hexValue >> 24) & 0xFF) / 255.0;
            *red = ((hexValue >> 16) & 0xFF) / 255.0;
            *green = ((hexValue >> 8) & 0xFF) / 255.0;
            *blue = (hexValue & 0xFF) / 255.0;
            return YES;
        default:
            return NO;
    }
}

@implementation UIColor (OCBAdditions)

+ (UIColor *)ocb_colorWithHexValue:(uint32_t)hexValue
{
    return [self ocb_colorWithHexValue:hexValue alpha:1.0];
}

+ (UIColor *)ocb_colorWithHexValue:(uint32_t)hexValue alpha:(CGFloat)alpha
{
    CGFloat red = ((hexValue >> 16) & 0xFF) / 255.0;
    CGFloat green = ((hexValue >> 8) & 0xFF) / 255.0;
    CGFloat blue = (hexValue & 0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:OCB_CLAMP(alpha, 0.0, 1.0)];
}

+ (nullable UIColor *)ocb_colorWithHexString:(NSString *)hexString
{
    return [self ocb_colorWithHexString:hexString alpha:1.0];
}

+ (nullable UIColor *)ocb_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat parsedAlpha = 1.0;
    if (!OCBHexStringToRGBAComponents(hexString, &red, &green, &blue, &parsedAlpha)) {
        return nil;
    }

    return [UIColor colorWithRed:red
                           green:green
                            blue:blue
                           alpha:OCB_CLAMP(parsedAlpha * alpha, 0.0, 1.0)];
}

@end
