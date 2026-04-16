#import "OCBDemoModule.h"

#import "OCBDemoBootstrapTask.h"
#import "OCBDemoHomeViewController.h"
#import "OCBDemoRouteCatalog.h"

OCB_EXPORT_MODULE(OCBDemoModule)

@interface OCBDemoModule ()

@property (nonatomic, weak) OCBAppContext *appContext;

@end

@implementation OCBDemoModule

- (NSString *)moduleName
{
    return @"demo";
}

- (void)registerRoutesWithRouter:(OCBRouter *)router
{
    [router registerRoute:OCBDemoRouteRoot factory:^UIViewController * _Nullable(NSDictionary * _Nullable params) {
        return [[OCBDemoHomeViewController alloc] initWithAppContext:self.appContext];
    }];
}

- (NSArray<id<OCBLaunchTask>> *)launchTasks
{
    return @[
        [[OCBDemoBootstrapTask alloc] init]
    ];
}

- (void)moduleDidRegisterWithContext:(OCBAppContext *)appContext
{
    self.appContext = appContext;
}

@end
