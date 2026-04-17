#import "OCBProfileModule.h"

#import <Core/OCBAppContext.h>
#import <Core/OCBAutoRegister.h>
#import <Core/OCBRouter.h>
#import "OCBProfileBootstrapTask.h"
#import "UI/OCBProfileViewController.h"

OCB_EXPORT_MODULE(OCBProfileModule)

@interface OCBProfileModule ()

@property (nonatomic, weak) OCBAppContext *appContext;

@end

@implementation OCBProfileModule

- (NSString *)moduleName
{
    return @"profile";
}

- (void)registerRoutesWithRouter:(OCBRouter *)router
{
    [router registerRoute:@"ocb://profile" factory:^UIViewController * _Nullable(NSDictionary * _Nullable params) {
        return [[OCBProfileViewController alloc] initWithAppContext:self.appContext];
    }];
}

- (NSArray<id<OCBLaunchTask>> *)launchTasks
{
    return @[
        [[OCBProfileBootstrapTask alloc] init]
    ];
}

- (void)moduleDidRegisterWithContext:(OCBAppContext *)appContext
{
    self.appContext = appContext;
}

@end
