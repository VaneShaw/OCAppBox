#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBAppContext;
@protocol OCBModuleProtocol;

@interface OCBModuleManager : NSObject

@property (nonatomic, strong, readonly) NSArray<id<OCBModuleProtocol>> *modules;

- (instancetype)initWithAppContext:(OCBAppContext *)appContext NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)autoRegisterModules;
- (void)registerModule:(id<OCBModuleProtocol>)module;
- (void)startWithLaunchOptions:(nullable NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END
