#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OCBListState) {
    OCBListStateContent = 0,
    OCBListStateLoading = 1,
    OCBListStateEmpty = 2,
    OCBListStateError = 3,
};

typedef void (^OCBListStateRetryHandler)(void);

@interface OCBListStateContainerView : UIView

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, assign, readonly) OCBListState state;
@property (nonatomic, copy, nullable) OCBListStateRetryHandler retryHandler;

- (void)showContent;
- (void)showLoadingWithText:(nullable NSString *)text;
- (void)showEmptyWithTitle:(NSString *)title detail:(nullable NSString *)detail;
- (void)showErrorWithTitle:(NSString *)title detail:(nullable NSString *)detail;

@end

NS_ASSUME_NONNULL_END
