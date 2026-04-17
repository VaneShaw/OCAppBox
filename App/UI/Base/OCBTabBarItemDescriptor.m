#import "OCBTabBarItemDescriptor.h"

@implementation OCBTabBarItemDescriptor

+ (instancetype)itemWithTitle:(NSString *)title
                    routePath:(NSString *)routePath
              systemImageName:(nullable NSString *)systemImageName
{
    return [self itemWithTitle:title
                     routePath:routePath
               systemImageName:systemImageName
       selectedSystemImageName:nil];
}

+ (instancetype)itemWithTitle:(NSString *)title
                    routePath:(NSString *)routePath
              systemImageName:(nullable NSString *)systemImageName
      selectedSystemImageName:(nullable NSString *)selectedSystemImageName
{
    return [self itemWithTitle:title
                     routePath:routePath
                   routeParams:nil
               systemImageName:systemImageName
       selectedSystemImageName:selectedSystemImageName];
}

+ (instancetype)itemWithTitle:(NSString *)title
                    routePath:(NSString *)routePath
                  routeParams:(nullable NSDictionary *)routeParams
              systemImageName:(nullable NSString *)systemImageName
      selectedSystemImageName:(nullable NSString *)selectedSystemImageName
{
    return [[self alloc] initWithTitle:title
                             routePath:routePath
                           routeParams:routeParams
                       systemImageName:systemImageName
               selectedSystemImageName:selectedSystemImageName];
}

- (instancetype)initWithTitle:(NSString *)title
                    routePath:(NSString *)routePath
                  routeParams:(nullable NSDictionary *)routeParams
              systemImageName:(nullable NSString *)systemImageName
      selectedSystemImageName:(nullable NSString *)selectedSystemImageName
{
    self = [super init];
    if (self) {
        _title = [title copy] ?: @"";
        _routePath = [routePath copy] ?: @"";
        _routeParams = [routeParams copy] ?: @{};
        _systemImageName = [systemImageName copy];
        _selectedSystemImageName = [selectedSystemImageName copy];
    }
    return self;
}

@end
