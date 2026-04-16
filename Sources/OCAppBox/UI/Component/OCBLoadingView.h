#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCBLoadingView : UIView

@property (nonatomic, copy) NSString *text;

- (void)startAnimating;
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
