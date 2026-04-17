#import "OCB__MODULE_NAME__Module.h"

#import <Core/OCBAppContext.h>
#import <Core/OCBAutoRegister.h>
#import <Core/OCBRouter.h>
#import "OCB__MODULE_NAME__BootstrapTask.h"
#import "UI/OCB__MODULE_NAME__ViewController.h"

OCB_EXPORT_MODULE(OCB__MODULE_NAME__Module)

@interface OCB__MODULE_NAME__Module ()

@property (nonatomic, weak) OCBAppContext *appContext;

@end

@implementation OCB__MODULE_NAME__Module

- (NSString *)moduleName
{
    return @"__MODULE_IDENTIFIER__";
}

- (void)registerRoutesWithRouter:(OCBRouter *)router
{
    [router registerRoute:@"__ROUTE_PATH__" factory:^UIViewController * _Nullable(NSDictionary * _Nullable params) {
        return [[OCB__MODULE_NAME__ViewController alloc] initWithAppContext:self.appContext];
    }];
}

- (NSArray<id<OCBLaunchTask>> *)launchTasks
{
    return @[
        [[OCB__MODULE_NAME__BootstrapTask alloc] init]
    ];
}

- (void)moduleDidRegisterWithContext:(OCBAppContext *)appContext
{
    self.appContext = appContext;
}

@end
