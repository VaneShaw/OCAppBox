#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBAppContext;

typedef NS_ENUM(NSInteger, OCBLaunchStage) {
    OCBLaunchStageBootstrap = 0,
    OCBLaunchStageService = 100,
    OCBLaunchStageModule = 200,
    OCBLaunchStageUI = 300,
};

@protocol OCBLaunchTask <NSObject>

@property (nonatomic, copy, readonly) NSString *taskIdentifier;
@property (nonatomic, assign, readonly) OCBLaunchStage stage;
@property (nonatomic, assign, readonly) NSInteger priority;

- (void)performWithAppContext:(OCBAppContext *)appContext
                launchOptions:(nullable NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END
