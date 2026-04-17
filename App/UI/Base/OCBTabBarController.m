#import "OCBTabBarController.h"

#import "OCBTabBarItemDescriptor.h"
#import "OCBNavController.h"
#import "../Theme/OCBThemeManager.h"
#import "../../Core/OCBAppContext.h"
#import "../../Core/OCBRouter.h"

@interface OCBTabBarController ()

@property (nonatomic, weak) OCBAppContext *appContext;
@property (nonatomic, copy) NSArray<OCBTabBarItemDescriptor *> *tabDescriptors;

@end

@implementation OCBTabBarController

- (instancetype)initWithAppContext:(OCBAppContext *)appContext
                    tabDescriptors:(NSArray<OCBTabBarItemDescriptor *> *)tabDescriptors
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _appContext = appContext;
        _tabDescriptors = [tabDescriptors copy] ?: @[];
        [self reloadTabs];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    OCBThemeManager *theme = [OCBThemeManager sharedManager];
    self.view.backgroundColor = theme.backgroundColor;

    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor whiteColor];
    self.tabBar.tintColor = theme.tintColor;
    self.tabBar.unselectedItemTintColor = theme.secondaryTextColor;
    self.tabBar.standardAppearance = appearance;
    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = appearance;
    }

    [self reloadTabs];
}

- (void)reloadTabs
{
    NSMutableArray<UIViewController *> *controllers = [[NSMutableArray alloc] init];
    [self.tabDescriptors enumerateObjectsUsingBlock:^(OCBTabBarItemDescriptor *descriptor, NSUInteger idx, BOOL *stop) {
        UIViewController *rootViewController = [self.appContext.router viewControllerForRoute:descriptor.routePath
                                                                                        params:descriptor.routeParams];
        if (rootViewController == nil) {
            rootViewController = [self fallbackControllerForDescriptor:descriptor];
        }

        OCBNavController *navigationController = [[OCBNavController alloc] initWithRootViewController:rootViewController];
        navigationController.tabBarItem.title = descriptor.title;
        if (descriptor.systemImageName.length > 0) {
            navigationController.tabBarItem.image = [UIImage systemImageNamed:descriptor.systemImageName];
        }
        if (descriptor.selectedSystemImageName.length > 0) {
            navigationController.tabBarItem.selectedImage = [UIImage systemImageNamed:descriptor.selectedSystemImageName];
        }

        [controllers addObject:navigationController];
    }];

    self.viewControllers = controllers;
}

- (UIViewController *)fallbackControllerForDescriptor:(OCBTabBarItemDescriptor *)descriptor
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = descriptor.title;
    viewController.view.backgroundColor = [OCBThemeManager sharedManager].backgroundColor;

    UILabel *label = [[UILabel alloc] initWithFrame:viewController.view.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [OCBThemeManager sharedManager].primaryTextColor;
    label.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium];
    label.text = [NSString stringWithFormat:@"Missing tab route:\n%@", descriptor.routePath];
    [viewController.view addSubview:label];

    return viewController;
}

@end
