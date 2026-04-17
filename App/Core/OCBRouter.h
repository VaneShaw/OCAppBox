#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef UIViewController * _Nullable (^OCBRouteFactory)(NSDictionary * _Nullable params);

@interface OCBRouter : NSObject

- (void)registerRoute:(NSString *)routePath factory:(OCBRouteFactory)factory;
- (nullable UIViewController *)viewControllerForRoute:(NSString *)routePath
                                               params:(nullable NSDictionary *)params;
- (BOOL)openRoute:(NSString *)routePath
           params:(nullable NSDictionary *)params
             from:(UIViewController *)sourceViewController
         animated:(BOOL)animated;
- (NSArray<NSString *> *)allRoutes;

@end

NS_ASSUME_NONNULL_END
