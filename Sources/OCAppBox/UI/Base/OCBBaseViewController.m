#import "OCBBaseViewController.h"

#import "OCBEmptyStateView.h"
#import "OCBLoadingView.h"
#import "OCBThemeManager.h"

@interface OCBBaseViewController ()

@property (nonatomic, strong, readwrite) OCBLoadingView *loadingView;
@property (nonatomic, strong, readwrite) OCBEmptyStateView *emptyStateView;

@end

@implementation OCBBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    OCBThemeManager *theme = [OCBThemeManager sharedManager];
    self.view.backgroundColor = theme.backgroundColor;
    self.view.tintColor = theme.tintColor;

    _loadingView = [[OCBLoadingView alloc] initWithFrame:self.view.bounds];
    _emptyStateView = [[OCBEmptyStateView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_emptyStateView];
    [self.view addSubview:_loadingView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.loadingView.frame = self.view.bounds;
    self.emptyStateView.frame = self.view.bounds;
}

- (void)showLoadingWithText:(nullable NSString *)text
{
    [self.view bringSubviewToFront:self.loadingView];
    self.loadingView.text = text ?: @"Loading";
    [self.loadingView startAnimating];
}

- (void)hideLoading
{
    [self.loadingView stopAnimating];
}

- (void)showEmptyWithTitle:(NSString *)title detail:(nullable NSString *)detail
{
    [self.view bringSubviewToFront:self.emptyStateView];
    [self.emptyStateView updateWithTitle:title detail:detail];
    self.emptyStateView.hidden = NO;
}

- (void)hideEmpty
{
    self.emptyStateView.hidden = YES;
}

@end
