#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (OCBAdditions)

+ (UIColor *)ocb_colorWithHexValue:(uint32_t)hexValue;
+ (UIColor *)ocb_colorWithHexValue:(uint32_t)hexValue alpha:(CGFloat)alpha;
+ (nullable UIColor *)ocb_colorWithHexString:(NSString *)hexString;
+ (nullable UIColor *)ocb_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
