#import "UIView+OCBAdditions.h"

@implementation UIView (OCBAdditions)

- (CGFloat)ocb_x
{
    return CGRectGetMinX(self.frame);
}

- (void)setOcb_x:(CGFloat)ocb_x
{
    CGRect frame = self.frame;
    frame.origin.x = ocb_x;
    self.frame = frame;
}

- (CGFloat)ocb_y
{
    return CGRectGetMinY(self.frame);
}

- (void)setOcb_y:(CGFloat)ocb_y
{
    CGRect frame = self.frame;
    frame.origin.y = ocb_y;
    self.frame = frame;
}

- (CGFloat)ocb_width
{
    return CGRectGetWidth(self.frame);
}

- (void)setOcb_width:(CGFloat)ocb_width
{
    CGRect frame = self.frame;
    frame.size.width = ocb_width;
    self.frame = frame;
}

- (CGFloat)ocb_height
{
    return CGRectGetHeight(self.frame);
}

- (void)setOcb_height:(CGFloat)ocb_height
{
    CGRect frame = self.frame;
    frame.size.height = ocb_height;
    self.frame = frame;
}

- (CGFloat)ocb_maxX
{
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)ocb_maxY
{
    return CGRectGetMaxY(self.frame);
}

- (UIEdgeInsets)ocb_safeAreaInsetsCompatible
{
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }

    return UIEdgeInsetsZero;
}

- (CGFloat)ocb_cornerRadius
{
    return self.layer.cornerRadius;
}

- (void)setOcb_cornerRadius:(CGFloat)ocb_cornerRadius
{
    self.layer.cornerRadius = MAX(0.0, ocb_cornerRadius);
    self.layer.masksToBounds = ocb_cornerRadius > 0.0;
}

- (void)ocb_removeAllSubviews
{
    NSArray<UIView *> *subviews = [self.subviews copy];
    [subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
}

@end
