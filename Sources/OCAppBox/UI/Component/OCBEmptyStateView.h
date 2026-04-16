#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^OCBEmptyStateActionHandler)(void);

@interface OCBEmptyStateView : UIView

- (void)updateWithTitle:(NSString *)title detail:(nullable NSString *)detail;
- (void)updateWithTitle:(NSString *)title
                 detail:(nullable NSString *)detail
            actionTitle:(nullable NSString *)actionTitle
          actionHandler:(nullable OCBEmptyStateActionHandler)actionHandler;

@end

NS_ASSUME_NONNULL_END
