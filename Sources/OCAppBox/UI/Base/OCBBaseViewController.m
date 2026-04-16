#import "OCBBaseViewController.h"

#import "OCBEmptyStateView.h"
#import "OCBLoadingView.h"
#import "OCBToast.h"
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
    [self hideEmpty];
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
    [self showEmptyWithTitle:title detail:detail actionTitle:nil actionHandler:nil];
}

- (void)showEmptyWithTitle:(NSString *)title
                    detail:(nullable NSString *)detail
               actionTitle:(nullable NSString *)actionTitle
             actionHandler:(nullable dispatch_block_t)actionHandler
{
    [self hideLoading];
    [self.view bringSubviewToFront:self.emptyStateView];
    [self.emptyStateView updateWithTitle:title detail:detail actionTitle:actionTitle actionHandler:actionHandler];
    self.emptyStateView.hidden = NO;
}

- (void)showErrorWithTitle:(NSString *)title
                    detail:(nullable NSString *)detail
                retryTitle:(nullable NSString *)retryTitle
              retryHandler:(nullable dispatch_block_t)retryHandler
{
    NSString *actionTitle = retryTitle.length > 0 ? retryTitle : @"Retry";
    [self showEmptyWithTitle:title detail:detail actionTitle:actionTitle actionHandler:retryHandler];
}

- (void)hideEmpty
{
    self.emptyStateView.hidden = YES;
}

- (void)showToastWithText:(NSString *)text
{
    [OCBToast showText:text inView:self.view];
}

@end
