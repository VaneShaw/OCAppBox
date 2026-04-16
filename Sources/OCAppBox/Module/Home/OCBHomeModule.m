#import "OCBHomeModule.h"

#import "OCBAppContext.h"
#import "OCBAutoRegister.h"
#import "OCBRouter.h"
#import "OCBHomeBootstrapTask.h"
#import "UI/OCBHomeViewController.h"

OCB_EXPORT_MODULE(OCBHomeModule)

@interface OCBHomeModule ()

@property (nonatomic, weak) OCBAppContext *appContext;

@end

@implementation OCBHomeModule

- (NSString *)moduleName
{
    return @"home";
}

- (void)registerRoutesWithRouter:(OCBRouter *)router
{
    [router registerRoute:@"ocb://home" factory:^UIViewController * _Nullable(NSDictionary * _Nullable params) {
        return [[OCBHomeViewController alloc] initWithAppContext:self.appContext];
    }];
}

- (NSArray<id<OCBLaunchTask>> *)launchTasks
{
    return @[
        [[OCBHomeBootstrapTask alloc] init]
    ];
}

- (void)moduleDidRegisterWithContext:(OCBAppContext *)appContext
{
    self.appContext = appContext;
}

@end
