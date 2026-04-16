#import "OCBRouter.h"

@interface OCBRouter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, OCBRouteFactory> *routeMap;

@end

@implementation OCBRouter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _routeMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerRoute:(NSString *)routePath factory:(OCBRouteFactory)factory
{
    if (routePath.length == 0 || factory == nil) {
        return;
    }

    @synchronized (self) {
        self.routeMap[routePath] = [factory copy];
    }
}

- (nullable UIViewController *)viewControllerForRoute:(NSString *)routePath
                                               params:(nullable NSDictionary *)params
{
    if (routePath.length == 0) {
        return nil;
    }

    OCBRouteFactory factory = nil;
    @synchronized (self) {
        factory = self.routeMap[routePath];
    }

    if (factory == nil) {
        return nil;
    }

    return factory(params);
}

- (BOOL)openRoute:(NSString *)routePath
           params:(nullable NSDictionary *)params
             from:(UIViewController *)sourceViewController
         animated:(BOOL)animated
{
    UIViewController *targetViewController = [self viewControllerForRoute:routePath params:params];
    if (targetViewController == nil) {
        return NO;
    }

    UINavigationController *navigationController = sourceViewController.navigationController;
    if (navigationController != nil) {
        [navigationController pushViewController:targetViewController animated:animated];
        return YES;
    }

    [sourceViewController presentViewController:targetViewController animated:animated completion:nil];
    return YES;
}

- (NSArray<NSString *> *)allRoutes
{
    @synchronized (self) {
        return [[self.routeMap allKeys] sortedArrayUsingSelector:@selector(compare:)];
    }
}

@end
