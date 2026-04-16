#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBEmptyStateView;
@class OCBLoadingView;

@interface OCBBaseViewController : UIViewController

@property (nonatomic, strong, readonly) OCBLoadingView *loadingView;
@property (nonatomic, strong, readonly) OCBEmptyStateView *emptyStateView;

- (void)showLoadingWithText:(nullable NSString *)text;
- (void)hideLoading;
- (void)showEmptyWithTitle:(NSString *)title detail:(nullable NSString *)detail;
- (void)hideEmpty;

@end

NS_ASSUME_NONNULL_END
