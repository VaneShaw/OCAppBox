#import "OCBDemoHomeViewController.h"

#import "OCBDemoRouteCatalog.h"

@interface OCBDemoHomeViewController ()

@property (nonatomic, weak) OCBAppContext *appContext;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *heroCardView;
@property (nonatomic, strong) UIView *routesCardView;
@property (nonatomic, strong) UIView *actionsCardView;
@property (nonatomic, strong) UIView *statusCardView;
@property (nonatomic, strong) UILabel *eyebrowLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *routesTitleLabel;
@property (nonatomic, strong) UILabel *actionsTitleLabel;
@property (nonatomic, strong) UILabel *statusTitleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *frameworkHomeButton;
@property (nonatomic, strong) UIButton *accountButton;
@property (nonatomic, strong) UIButton *debugButton;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *permissionButton;
@property (nonatomic, strong) UIButton *emptyButton;
@property (nonatomic, assign) BOOL presentingEmptyState;

@end

@implementation OCBDemoHomeViewController

- (instancetype)initWithAppContext:(OCBAppContext *)appContext
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _appContext = appContext;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Example";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:self.contentView];
    [self.view addSubview:self.scrollView];

    self.heroCardView = [self cardViewWithBackgroundColor:[UIColor whiteColor]];
    self.routesCardView = [self cardViewWithBackgroundColor:[UIColor whiteColor]];
    self.actionsCardView = [self cardViewWithBackgroundColor:[UIColor whiteColor]];
    self.statusCardView = [self cardViewWithBackgroundColor:[UIColor whiteColor]];

    self.eyebrowLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.eyebrowLabel.attributedText = [self eyebrowAttributedString];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.text = @"Example Host Template";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:30.0];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor = [OCBThemeManager sharedManager].primaryTextColor;
    self.titleLabel.numberOfLines = 0;

    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.textAlignment = NSTextAlignmentLeft;
    self.detailLabel.font = [UIFont systemFontOfSize:16.0];
    self.detailLabel.textColor = [OCBThemeManager sharedManager].secondaryTextColor;
    self.detailLabel.text = @"这个页面是 Example 宿主层入口，负责承接框架模块、调试面板和基础服务的联调验证。";

    self.routesTitleLabel = [self sectionTitleLabelWithText:@"Quick Routes"];
    self.actionsTitleLabel = [self sectionTitleLabelWithText:@"Service Actions"];
    self.statusTitleLabel = [self sectionTitleLabelWithText:@"Runtime Snapshot"];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.textAlignment = NSTextAlignmentLeft;
    self.statusLabel.font = [UIFont monospacedSystemFontOfSize:14.0 weight:UIFontWeightRegular];
    self.statusLabel.textColor = [OCBThemeManager sharedManager].primaryTextColor;

    self.frameworkHomeButton = [self actionButtonWithTitle:@"进入 Framework Home"
                                           backgroundColor:[OCBThemeManager sharedManager].tintColor
                                                    action:@selector(openFrameworkHome)];
    self.accountButton = [self actionButtonWithTitle:@"进入 Account 模块"
                                     backgroundColor:[[OCBThemeManager sharedManager].tintColor colorWithAlphaComponent:0.88]
                                              action:@selector(openAccountModule)];
    self.debugButton = [self actionButtonWithTitle:@"开发调试面板"
                                   backgroundColor:[[OCBThemeManager sharedManager].secondaryTextColor colorWithAlphaComponent:0.92]
                                            action:@selector(openDebugPanel)];
    self.loginButton = [self actionButtonWithTitle:@"模拟登录"
                                   backgroundColor:[[OCBThemeManager sharedManager].primaryTextColor colorWithAlphaComponent:0.92]
                                            action:@selector(toggleLoginState)];
    self.permissionButton = [self actionButtonWithTitle:@"请求相机权限"
                                        backgroundColor:[[OCBThemeManager sharedManager].primaryTextColor colorWithAlphaComponent:0.78]
                                                 action:@selector(requestCameraPermission)];
    self.emptyButton = [self actionButtonWithTitle:@"切换空态"
                                   backgroundColor:[[OCBThemeManager sharedManager].primaryTextColor colorWithAlphaComponent:0.66]
                                            action:@selector(toggleEmptyState)];

    [self.contentView addSubview:self.heroCardView];
    [self.contentView addSubview:self.routesCardView];
    [self.contentView addSubview:self.actionsCardView];
    [self.contentView addSubview:self.statusCardView];

    [self.heroCardView addSubview:self.eyebrowLabel];
    [self.heroCardView addSubview:self.titleLabel];
    [self.heroCardView addSubview:self.detailLabel];

    [self.routesCardView addSubview:self.routesTitleLabel];
    [self.routesCardView addSubview:self.frameworkHomeButton];
    [self.routesCardView addSubview:self.accountButton];
    [self.routesCardView addSubview:self.debugButton];

    [self.actionsCardView addSubview:self.actionsTitleLabel];
    [self.actionsCardView addSubview:self.loginButton];
    [self.actionsCardView addSubview:self.permissionButton];
    [self.actionsCardView addSubview:self.emptyButton];

    [self.statusCardView addSubview:self.statusTitleLabel];
    [self.statusCardView addSubview:self.statusLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleServiceNotification:)
                                                 name:OCBUserSessionDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleServiceNotification:)
                                                 name:OCBRemoteConfigDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleServiceNotification:)
                                                 name:OCBPermissionDidChangeNotification
                                               object:nil];

    [self showLoadingWithText:@"Preparing example host"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideLoading];
        [self reloadServiceState];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    UIEdgeInsets safeInsets = self.view.safeAreaInsets;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    self.scrollView.frame = CGRectMake(0.0, safeInsets.top, width, height - safeInsets.top - safeInsets.bottom);

    CGFloat horizontalInset = 20.0;
    CGFloat cardWidth = width - (horizontalInset * 2.0);
    CGFloat cardPadding = 20.0;
    CGFloat buttonHeight = 52.0;
    CGFloat y = 12.0;

    CGFloat eyebrowWidth = cardWidth - (cardPadding * 2.0);
    CGSize eyebrowSize = [self.eyebrowLabel sizeThatFits:CGSizeMake(eyebrowWidth, CGFLOAT_MAX)];
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(eyebrowWidth, CGFLOAT_MAX)];
    CGSize detailSize = [self.detailLabel sizeThatFits:CGSizeMake(eyebrowWidth, CGFLOAT_MAX)];
    CGFloat heroHeight = cardPadding + eyebrowSize.height + 10.0 + titleSize.height + 14.0 + detailSize.height + cardPadding;

    self.heroCardView.frame = CGRectMake(horizontalInset, y, cardWidth, heroHeight);
    self.eyebrowLabel.frame = CGRectMake(cardPadding, cardPadding, eyebrowWidth, eyebrowSize.height);
    self.titleLabel.frame = CGRectMake(cardPadding, CGRectGetMaxY(self.eyebrowLabel.frame) + 10.0, eyebrowWidth, titleSize.height);
    self.detailLabel.frame = CGRectMake(cardPadding, CGRectGetMaxY(self.titleLabel.frame) + 14.0, eyebrowWidth, detailSize.height);
    y = CGRectGetMaxY(self.heroCardView.frame) + 16.0;

    CGFloat sectionTitleWidth = cardWidth - (cardPadding * 2.0);
    CGSize routesTitleSize = [self.routesTitleLabel sizeThatFits:CGSizeMake(sectionTitleWidth, CGFLOAT_MAX)];
    CGFloat routesHeight = cardPadding + routesTitleSize.height + 16.0 + buttonHeight + 12.0 + buttonHeight + 12.0 + buttonHeight + cardPadding;
    self.routesCardView.frame = CGRectMake(horizontalInset, y, cardWidth, routesHeight);
    self.routesTitleLabel.frame = CGRectMake(cardPadding, cardPadding, sectionTitleWidth, routesTitleSize.height);
    self.frameworkHomeButton.frame = CGRectMake(cardPadding, CGRectGetMaxY(self.routesTitleLabel.frame) + 16.0, sectionTitleWidth, buttonHeight);
    self.accountButton.frame = CGRectMake(cardPadding, CGRectGetMaxY(self.frameworkHomeButton.frame) + 12.0, sectionTitleWidth, buttonHeight);
    self.debugButton.frame = CGRectMake(cardPadding, CGRectGetMaxY(self.accountButton.frame) + 12.0, sectionTitleWidth, buttonHeight);
    y = CGRectGetMaxY(self.routesCardView.frame) + 16.0;

    CGSize actionsTitleSize = [self.actionsTitleLabel sizeThatFits:CGSizeMake(sectionTitleWidth, CGFLOAT_MAX)];
    CGFloat actionsHeight = cardPadding + actionsTitleSize.height + 16.0 + buttonHeight + 12.0 + buttonHeight + 12.0 + buttonHeight + cardPadding;
    self.actionsCardView.frame = CGRectMake(horizontalInset, y, cardWidth, actionsHeight);
    self.actionsTitleLabel.frame = CGRectMake(cardPadding, cardPadding, sectionTitleWidth, actionsTitleSize.height);
    self.loginButton.frame = CGRectMake(cardPadding, CGRectGetMaxY(self.actionsTitleLabel.frame) + 16.0, sectionTitleWidth, buttonHeight);
    self.permissionButton.frame = CGRectMake(cardPadding, CGRectGetMaxY(self.loginButton.frame) + 12.0, sectionTitleWidth, buttonHeight);
    self.emptyButton.frame = CGRectMake(cardPadding, CGRectGetMaxY(self.permissionButton.frame) + 12.0, sectionTitleWidth, buttonHeight);
    y = CGRectGetMaxY(self.actionsCardView.frame) + 16.0;

    CGSize statusTitleSize = [self.statusTitleLabel sizeThatFits:CGSizeMake(sectionTitleWidth, CGFLOAT_MAX)];
    CGSize statusSize = [self.statusLabel sizeThatFits:CGSizeMake(sectionTitleWidth, CGFLOAT_MAX)];
    CGFloat statusHeight = cardPadding + statusTitleSize.height + 14.0 + statusSize.height + cardPadding;
    self.statusCardView.frame = CGRectMake(horizontalInset, y, cardWidth, statusHeight);
    self.statusTitleLabel.frame = CGRectMake(cardPadding, cardPadding, sectionTitleWidth, statusTitleSize.height);
    self.statusLabel.frame = CGRectMake(cardPadding, CGRectGetMaxY(self.statusTitleLabel.frame) + 14.0, sectionTitleWidth, statusSize.height);
    y = CGRectGetMaxY(self.statusCardView.frame) + 24.0;

    self.contentView.frame = CGRectMake(0.0, 0.0, width, y);
    self.scrollView.contentSize = CGSizeMake(width, MAX(y, CGRectGetHeight(self.scrollView.bounds) + 1.0));
}

- (void)reloadServiceState
{
    id<OCBRemoteConfigProviding> remoteConfig = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBRemoteConfigProviding)];
    id<OCBUserSessionProviding> sessionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBUserSessionProviding)];
    id<OCBPermissionProviding> permissionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBPermissionProviding)];
    id<OCBStorageProviding> storage = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBStorageProviding)];

    NSString *headline = [remoteConfig stringValueForKey:@"home.headline" defaultValue:@"Example Host Template"];
    NSString *copy = [remoteConfig stringValueForKey:@"home.welcome.copy"
                                        defaultValue:@"Service 层已经接通，这个页面正在展示宿主入口、模块跳转、调试面板和基础服务。"];
    BOOL emptyStateEnabled = [remoteConfig boolValueForKey:@"feature.empty_state_demo" defaultValue:YES];
    OCBUserSession *session = sessionService.currentSession;
    OCBPermissionStatus permissionStatus = [permissionService statusForPermission:@"camera"];
    NSString *lastLaunch = [NSString ocb_stringWithObject:[storage diskObjectForKey:@"demo.lastLaunch"] defaultValue:@"n/a"];

    self.titleLabel.text = headline;
    self.detailLabel.text = copy;
    [self.loginButton setTitle:([sessionService isLoggedIn] ? @"退出登录" : @"模拟登录") forState:UIControlStateNormal];
    self.emptyButton.hidden = !emptyStateEnabled;
    if (!emptyStateEnabled && self.presentingEmptyState) {
        self.presentingEmptyState = NO;
        [self hideEmpty];
    }

    NSString *userName = session.displayName.length > 0 ? session.displayName : @"未登录";
    NSString *loginStatus = [sessionService isLoggedIn] ? @"已登录" : @"未登录";
    self.statusLabel.text = [NSString stringWithFormat:
        @"environment  %@\nmodules      %lu\nroutes       %lu\nservices     %lu\nlogin        %@\nuser         %@\npermission   %@\nlast launch  %@",
        self.appContext.environment,
        (unsigned long)self.appContext.moduleManager.modules.count,
        (unsigned long)self.appContext.router.allRoutes.count,
        (unsigned long)self.appContext.serviceRegistry.allRegisteredProtocolNames.count,
        loginStatus,
        userName,
        [self textForPermissionStatus:permissionStatus],
        lastLaunch];
    [self.view setNeedsLayout];
}

- (void)handleServiceNotification:(NSNotification *)notification
{
    [self reloadServiceState];
}

- (UIButton *)actionButtonWithTitle:(NSString *)title
                    backgroundColor:(UIColor *)backgroundColor
                             action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    button.backgroundColor = backgroundColor;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 12.0;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIView *)cardViewWithBackgroundColor:(UIColor *)backgroundColor
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = backgroundColor;
    view.layer.cornerRadius = 26.0;
    view.layer.borderWidth = 1.0;
    view.layer.borderColor = [[UIColor colorWithWhite:0.0 alpha:0.06] CGColor];
    view.layer.shadowColor = [[UIColor colorWithWhite:0.0 alpha:0.08] CGColor];
    view.layer.shadowOpacity = 1.0;
    view.layer.shadowRadius = 18.0;
    view.layer.shadowOffset = CGSizeMake(0.0, 10.0);
    return view;
}

- (UILabel *)sectionTitleLabelWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
    label.textColor = [OCBThemeManager sharedManager].secondaryTextColor;
    return label;
}

- (NSAttributedString *)eyebrowAttributedString
{
    NSDictionary<NSAttributedStringKey, id> *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:12.0 weight:UIFontWeightBold],
        NSForegroundColorAttributeName: [[OCBThemeManager sharedManager].tintColor colorWithAlphaComponent:0.85],
        NSKernAttributeName: @1.2
    };
    return [[NSAttributedString alloc] initWithString:@"HOST CONSOLE" attributes:attributes];
}

- (void)openFrameworkHome
{
    [self openRoute:OCBDemoRouteFrameworkHome
       missingTitle:@"Home Missing"
      missingDetail:@"Framework Home 模块还没有完成注册，请检查框架路由装配链路。"];
}

- (void)openAccountModule
{
    [self openRoute:OCBDemoRouteAccount
       missingTitle:@"Route Missing"
      missingDetail:@"Account 模块还没有完成注册，请检查 autoRegisterModules 调用链。"];
}

- (void)openDebugPanel
{
    [self openRoute:OCBDemoRouteDebugPanel
       missingTitle:@"Support Missing"
      missingDetail:@"调试面板还没有完成注册，请检查 Support 模块是否已经自动装配。"];
}

- (void)openRoute:(NSString *)routePath
     missingTitle:(NSString *)missingTitle
    missingDetail:(NSString *)missingDetail
{
    BOOL opened = [self.appContext.router openRoute:routePath
                                             params:nil
                                               from:self
                                           animated:YES];
    if (!opened) {
        [self showEmptyWithTitle:missingTitle detail:missingDetail];
    }
}

- (void)toggleEmptyState
{
    self.presentingEmptyState = !self.presentingEmptyState;
    if (self.presentingEmptyState) {
        [self showEmptyWithTitle:@"Empty State Ready"
                          detail:@"这里可以接列表空数据、搜索无结果、断网占位等通用场景。"];
    } else {
        [self hideEmpty];
    }
}

- (void)toggleLoginState
{
    id<OCBAuthenticating> authService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBAuthenticating)];
    id<OCBUserSessionProviding> sessionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBUserSessionProviding)];

    if ([sessionService isLoggedIn]) {
        [authService signOut];
        [self reloadServiceState];
        return;
    }

    [self showLoadingWithText:@"Signing in demo user"];
    [authService signInWithUserIdentifier:@"1001"
                              displayName:@"OCB Demo User"
                                    token:@"demo-token-1001"
                               completion:^(OCBUserSession *session, NSError *error) {
        [self hideLoading];
        [self reloadServiceState];
    }];
}

- (void)requestCameraPermission
{
    id<OCBPermissionProviding> permissionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBPermissionProviding)];
    id<OCBMutablePermissionProviding> mutablePermissionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBMutablePermissionProviding)];

    [self showLoadingWithText:@"Requesting camera permission"];
    [permissionService requestPermission:@"camera" completion:^(OCBPermissionStatus status) {
        if (status == OCBPermissionStatusUnknown) {
            [mutablePermissionService updateStatus:OCBPermissionStatusAuthorized forPermission:@"camera"];
        }
        [self hideLoading];
        [self reloadServiceState];
    }];
}

- (NSString *)textForPermissionStatus:(OCBPermissionStatus)status
{
    switch (status) {
        case OCBPermissionStatusUnknown:
            return @"unknown";
        case OCBPermissionStatusDenied:
            return @"denied";
        case OCBPermissionStatusAuthorized:
            return @"authorized";
        case OCBPermissionStatusRestricted:
            return @"restricted";
    }

    return @"unknown";
}

@end
