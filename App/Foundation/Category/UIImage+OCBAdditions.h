#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (OCBAdditions)

+ (UIImage *)ocb_imageWithColor:(UIColor *)color size:(CGSize)size;
- (UIImage *)ocb_resizedImageWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
