#import "UIImage+OCBAdditions.h"

@implementation UIImage (OCBAdditions)

+ (UIImage *)ocb_imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGSize imageSize = CGSizeMake(MAX(size.width, 1.0), MAX(size.height, 1.0));
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:imageSize];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [color setFill];
        [rendererContext fillRect:CGRectMake(0.0, 0.0, imageSize.width, imageSize.height)];
    }];
}

- (UIImage *)ocb_resizedImageWithSize:(CGSize)size
{
    CGSize imageSize = CGSizeMake(MAX(size.width, 1.0), MAX(size.height, 1.0));
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:imageSize];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [self drawInRect:CGRectMake(0.0, 0.0, imageSize.width, imageSize.height)];
    }];
}

@end
