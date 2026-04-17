#import "OCBDebugPanelModule.h"

#import "OCBAppContext.h"
#import "OCBAutoRegister.h"
#import "OCBRouter.h"
#import "UI/OCBDebugPanelViewController.h"

OCB_EXPORT_MODULE(OCBDebugPanelModule)

@interface OCBDebugPanelModule ()

@property (nonatomic, weak) OCBAppContext *appContext;

@end

@implementation OCBDebugPanelModule

- (NSString *)moduleName
{
    return @"support.debug";
}

- (void)registerRoutesWithRouter:(OCBRouter *)router
{
    [router registerRoute:@"ocb://support/debug" factory:^UIViewController * _Nullable(NSDictionary * _Nullable params) {
        return [[OCBDebugPanelViewController alloc] initWithAppContext:self.appContext];
    }];
}

- (void)moduleDidRegisterWithContext:(OCBAppContext *)appContext
{
    self.appContext = appContext;
}

@end
