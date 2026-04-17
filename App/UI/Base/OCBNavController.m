#import "OCBNavController.h"

#import "OCBThemeManager.h"

@implementation OCBNavController

- (void)viewDidLoad
{
    [super viewDidLoad];

    OCBThemeManager *theme = [OCBThemeManager sharedManager];
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor whiteColor];
    appearance.titleTextAttributes = @{NSForegroundColorAttributeName: theme.primaryTextColor};
    appearance.largeTitleTextAttributes = @{NSForegroundColorAttributeName: theme.primaryTextColor};

    self.navigationBar.prefersLargeTitles = YES;
    self.navigationBar.tintColor = theme.tintColor;
    self.navigationBar.standardAppearance = appearance;
    self.navigationBar.scrollEdgeAppearance = appearance;
    self.navigationBar.compactAppearance = appearance;
}

@end
