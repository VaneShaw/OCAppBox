#import "OCBToast.h"

#import "OCBThemeManager.h"

static NSTimeInterval const OCBToastDefaultDuration = 1.8;
static NSInteger const OCBToastLabelTag = 105014;

@implementation OCBToast

+ (void)showText:(NSString *)text
{
    UIView *containerView = [self defaultContainerView];
    if (containerView == nil) {
        return;
    }

    [self showText:text inView:containerView duration:OCBToastDefaultDuration];
}

+ (void)showText:(NSString *)text inView:(UIView *)view
{
    [self showText:text inView:view duration:OCBToastDefaultDuration];
}

+ (void)showText:(NSString *)text inView:(UIView *)view duration:(NSTimeInterval)duration
{
    if (text.length == 0 || view == nil) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *existingLabel = (UILabel *)[view viewWithTag:OCBToastLabelTag];
        [existingLabel.layer removeAllAnimations];
        [existingLabel removeFromSuperview];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = OCBToastLabelTag;
        label.alpha = 0.0;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = text;
        label.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [[OCBThemeManager sharedManager].primaryTextColor colorWithAlphaComponent:0.9];
        label.layer.cornerRadius = 14.0;
        label.layer.masksToBounds = YES;

        UIEdgeInsets safeInsets = view.safeAreaInsets;
        CGFloat maxWidth = MAX(160.0, CGRectGetWidth(view.bounds) - 48.0);
        CGSize textSize = [label sizeThatFits:CGSizeMake(maxWidth - 32.0, CGFLOAT_MAX)];
        CGFloat labelWidth = MIN(maxWidth, textSize.width + 32.0);
        CGFloat labelHeight = MAX(44.0, textSize.height + 22.0);
        CGFloat originX = floor((CGRectGetWidth(view.bounds) - labelWidth) * 0.5);
        CGFloat originY = CGRectGetHeight(view.bounds) - safeInsets.bottom - labelHeight - 36.0;
        label.frame = CGRectMake(originX, originY, labelWidth, labelHeight);

        [view addSubview:label];

        [UIView animateWithDuration:0.2 animations:^{
            label.alpha = 1.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25
                                  delay:MAX(0.8, duration)
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                label.alpha = 0.0;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
            }];
        }];
    });
}

+ (nullable UIView *)defaultContainerView
{
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }

            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if (windowScene.activationState != UISceneActivationStateForegroundActive) {
                continue;
            }

            for (UIWindow *window in windowScene.windows.reverseObjectEnumerator) {
                if (window.isHidden || window.alpha <= 0.0) {
                    continue;
                }
                return window;
            }
        }
    }

    return nil;
}

@end
