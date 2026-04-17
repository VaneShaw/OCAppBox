#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBAppContext;
@class OCBTabBarItemDescriptor;

@interface OCBTabBarController : UITabBarController

- (instancetype)initWithAppContext:(OCBAppContext *)appContext
                    tabDescriptors:(NSArray<OCBTabBarItemDescriptor *> *)tabDescriptors NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)reloadTabs;

@end

NS_ASSUME_NONNULL_END
