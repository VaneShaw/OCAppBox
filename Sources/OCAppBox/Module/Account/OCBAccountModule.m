#import "OCBAccountModule.h"

#import "OCBAppContext.h"
#import "OCBAutoRegister.h"
#import "OCBRouter.h"
#import "OCBAccountBootstrapTask.h"
#import "UI/OCBAccountViewController.h"

OCB_EXPORT_MODULE(OCBAccountModule)

@interface OCBAccountModule ()

@property (nonatomic, weak) OCBAppContext *appContext;

@end

@implementation OCBAccountModule

- (NSString *)moduleName
{
    return @"account";
}

- (void)registerRoutesWithRouter:(OCBRouter *)router
{
    [router registerRoute:@"ocb://account" factory:^UIViewController * _Nullable(NSDictionary * _Nullable params) {
        return [[OCBAccountViewController alloc] initWithAppContext:self.appContext];
    }];
}

- (NSArray<id<OCBLaunchTask>> *)launchTasks
{
    return @[
        [[OCBAccountBootstrapTask alloc] init]
    ];
}

- (void)moduleDidRegisterWithContext:(OCBAppContext *)appContext
{
    self.appContext = appContext;
}

@end
