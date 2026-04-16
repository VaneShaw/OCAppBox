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
- (void)showEmptyWithTitle:(NSString *)title
                    detail:(nullable NSString *)detail
               actionTitle:(nullable NSString *)actionTitle
             actionHandler:(nullable dispatch_block_t)actionHandler;
- (void)showErrorWithTitle:(NSString *)title
                    detail:(nullable NSString *)detail
                retryTitle:(nullable NSString *)retryTitle
              retryHandler:(nullable dispatch_block_t)retryHandler;
- (void)hideEmpty;
- (void)showToastWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
