#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBModuleManager;
@class OCBRouter;
@class OCBServiceRegistry;

@interface OCBAppContext : NSObject

@property (nonatomic, strong, nullable) UIWindow *window;
@property (nonatomic, copy, readonly) NSDictionary *launchOptions;
@property (nonatomic, copy) NSString *environment;
@property (nonatomic, strong, readonly) OCBModuleManager *moduleManager;
@property (nonatomic, strong, readonly) OCBRouter *router;
@property (nonatomic, strong, readonly) OCBServiceRegistry *serviceRegistry;

- (instancetype)initWithLaunchOptions:(nullable NSDictionary *)launchOptions NS_DESIGNATED_INITIALIZER;
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
