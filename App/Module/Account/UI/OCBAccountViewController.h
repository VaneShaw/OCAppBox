#import <UI/Base/OCBBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBAppContext;

@interface OCBAccountViewController : OCBBaseViewController

- (instancetype)initWithAppContext:(OCBAppContext *)appContext NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
