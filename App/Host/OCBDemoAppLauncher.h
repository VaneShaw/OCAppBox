#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class OCBAppContext;

NS_ASSUME_NONNULL_BEGIN

@interface OCBDemoAppLauncher : NSObject

@property (nonatomic, strong, readonly) OCBAppContext *appContext;

- (instancetype)initWithLaunchOptions:(nullable NSDictionary *)launchOptions NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)launchInWindow:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
