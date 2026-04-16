#import "__APP_PREFIX__Module.h"

#import "__APP_PREFIX__BootstrapTask.h"
#import "__APP_PREFIX__HomeViewController.h"
#import "__APP_PREFIX__RouteCatalog.h"

OCB_EXPORT_MODULE(__APP_PREFIX__Module)

@interface __APP_PREFIX__Module ()

@property (nonatomic, weak) OCBAppContext *appContext;

@end

@implementation __APP_PREFIX__Module

- (NSString *)moduleName
{
    return @"host.__APP_IDENTIFIER__";
}

- (void)registerRoutesWithRouter:(OCBRouter *)router
{
    [router registerRoute:__APP_PREFIX__RouteRoot factory:^UIViewController * _Nullable(NSDictionary * _Nullable params) {
        return [[__APP_PREFIX__HomeViewController alloc] initWithAppContext:self.appContext];
    }];
}

- (NSArray<id<OCBLaunchTask>> *)launchTasks
{
    return @[
        [[__APP_PREFIX__BootstrapTask alloc] init]
    ];
}

- (void)moduleDidRegisterWithContext:(OCBAppContext *)appContext
{
    self.appContext = appContext;
}

@end
