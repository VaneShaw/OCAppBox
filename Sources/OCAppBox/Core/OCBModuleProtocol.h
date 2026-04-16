#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBAppContext;
@class OCBRouter;
@class OCBServiceRegistry;
@protocol OCBLaunchTask;

@protocol OCBModuleProtocol <NSObject>

@property (nonatomic, copy, readonly) NSString *moduleName;

@optional
- (void)registerRoutesWithRouter:(OCBRouter *)router;
- (void)registerServicesWithServiceRegistry:(OCBServiceRegistry *)serviceRegistry;
- (NSArray<id<OCBLaunchTask>> *)launchTasks;
- (void)moduleDidRegisterWithContext:(OCBAppContext *)appContext;

@end

NS_ASSUME_NONNULL_END
