#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <math.h>
#import "UIColor+OCBAdditions.h"

#ifndef OCBFoundationMacros_h
#define OCBFoundationMacros_h

#define OCB_WEAKIFY(VAR) __weak typeof(VAR) weak##VAR = (VAR)
#define OCB_STRONGIFY(VAR) __strong typeof(weak##VAR) VAR = weak##VAR

#define OCB_SAFE_BLOCK(BLOCK, ...) \
    do { \
        if ((BLOCK) != nil) { \
            (BLOCK)(__VA_ARGS__); \
        } \
    } while (0)

#define OCB_DISPATCH_MAIN_ASYNC_SAFE(BLOCK) \
    do { \
        if ([NSThread isMainThread]) { \
            (BLOCK)(); \
        } else { \
            dispatch_async(dispatch_get_main_queue(), (BLOCK)); \
        } \
    } while (0)

#define OCB_DISPATCH_MAIN_SYNC_SAFE(BLOCK) \
    do { \
        if ([NSThread isMainThread]) { \
            (BLOCK)(); \
        } else { \
            dispatch_sync(dispatch_get_main_queue(), (BLOCK)); \
        } \
    } while (0)

#define OCB_SCREEN_BOUNDS ([UIScreen mainScreen].bounds)
#define OCB_SCREEN_WIDTH CGRectGetWidth(OCB_SCREEN_BOUNDS)
#define OCB_SCREEN_HEIGHT CGRectGetHeight(OCB_SCREEN_BOUNDS)
#define OCB_ONE_PIXEL (1.0 / MAX([UIScreen mainScreen].scale, 1.0))
#define OCB_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define OCB_CLAMP(VALUE, LOWER, UPPER) \
    (((VALUE) < (LOWER)) ? (LOWER) : (((VALUE) > (UPPER)) ? (UPPER) : (VALUE)))

#define OCB_DEGREES_TO_RADIANS(ANGLE) ((ANGLE) * ((CGFloat)M_PI / 180.0))
#define OCB_RADIANS_TO_DEGREES(RADIANS) ((RADIANS) * (180.0 / (CGFloat)M_PI))

#define OCB_SAFE_CAST(OBJECT, CLASS) ([(OBJECT) isKindOfClass:[CLASS class]] ? (CLASS *)(OBJECT) : nil)

#define OCBLocalizedString(KEY) NSLocalizedString((KEY), nil)
#define OCBLocalizedStringFromTable(KEY, TABLE) NSLocalizedStringFromTable((KEY), (TABLE), nil)

#define OCB_STRINGIFY(VALUE) [NSString stringWithFormat:@"%@", (VALUE) ?: @""]

#define OCBColorHex(VALUE) [UIColor ocb_colorWithHexValue:(VALUE)]
#define OCBColorHexA(VALUE, ALPHA) [UIColor ocb_colorWithHexValue:(VALUE) alpha:(ALPHA)]

#endif /* OCBFoundationMacros_h */
