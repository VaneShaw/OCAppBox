#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (OCBAdditions)

@property (nonatomic, assign) CGFloat ocb_x;
@property (nonatomic, assign) CGFloat ocb_y;
@property (nonatomic, assign) CGFloat ocb_width;
@property (nonatomic, assign) CGFloat ocb_height;
@property (nonatomic, assign, readonly) CGFloat ocb_maxX;
@property (nonatomic, assign, readonly) CGFloat ocb_maxY;
@property (nonatomic, assign, readonly) UIEdgeInsets ocb_safeAreaInsetsCompatible;
@property (nonatomic, assign) CGFloat ocb_cornerRadius;

- (void)ocb_removeAllSubviews;

@end

NS_ASSUME_NONNULL_END
