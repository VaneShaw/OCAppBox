#import "__APP_PREFIX__HomeViewController.h"

#import "__APP_PREFIX__RouteCatalog.h"

@interface __APP_PREFIX__HomeViewController ()

@property (nonatomic, weak) OCBAppContext *appContext;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIStackView *rootStackView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *frameworkHomeButton;
@property (nonatomic, strong) UIButton *accountButton;
@property (nonatomic, strong) UIButton *debugButton;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *permissionButton;
@property (nonatomic, strong) UIButton *emptyButton;
@property (nonatomic, assign) BOOL presentingEmptyState;

@end

@implementation __APP_PREFIX__HomeViewController

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

    self.title = @"__APP_DISPLAY_NAME__";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;

    [self buildLayout];
    [self bindNotifications];

    [self showLoadingWithText:@"Preparing __APP_DISPLAY_NAME__"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideLoading];
        [self reloadRuntimeSnapshot];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildLayout
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;

    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

    self.rootStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.rootStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rootStackView.axis = UILayoutConstraintAxisVertical;
    self.rootStackView.spacing = 16.0;

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.contentView addSubview:self.rootStackView];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],

        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor],

        [self.rootStackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:16.0],
        [self.rootStackView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20.0],
        [self.rootStackView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20.0],
        [self.rootStackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-24.0]
    ]];

    [self.rootStackView addArrangedSubview:[self buildHeroCard]];
    [self.rootStackView addArrangedSubview:[self buildRoutesCard]];
    [self.rootStackView addArrangedSubview:[self buildActionsCard]];
    [self.rootStackView addArrangedSubview:[self buildStatusCard]];
}

- (void)bindNotifications
{
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
}

- (UIView *)buildHeroCard
{
    UIView *card = [self cardContainer];
    UIStackView *stackView = [self contentStackViewInCard:card spacing:12.0];

    UILabel *eyebrowLabel = [self eyebrowLabel];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont systemFontOfSize:28.0 weight:UIFontWeightBold];
    self.titleLabel.textColor = [OCBThemeManager sharedManager].primaryTextColor;
    self.titleLabel.text = @"__APP_DISPLAY_NAME__ Host Ready";

    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.font = [UIFont systemFontOfSize:16.0];
    self.detailLabel.textColor = [OCBThemeManager sharedManager].secondaryTextColor;
    self.detailLabel.text = @"宿主工程已经接通路由、服务和调试入口，可以直接从这里继续搭页面。";

    [stackView addArrangedSubview:eyebrowLabel];
    [stackView addArrangedSubview:self.titleLabel];
    [stackView addArrangedSubview:self.detailLabel];

    return card;
}

- (UIView *)buildRoutesCard
{
    UIView *card = [self cardContainer];
    UIStackView *stackView = [self contentStackViewInCard:card spacing:12.0];

    [stackView addArrangedSubview:[self sectionTitleLabelWithText:@"Quick Routes"]];
    [stackView addArrangedSubview:[self captionLabelWithText:@"用宿主首页直接验证框架模块、账号模块和调试面板的接入状态。"]];

    self.frameworkHomeButton = [self actionButtonWithTitle:@"进入 Framework Home"
                                           backgroundColor:[OCBThemeManager sharedManager].tintColor
                                                    action:@selector(openFrameworkHome)];
    self.accountButton = [self actionButtonWithTitle:@"进入 Account 模块"
                                     backgroundColor:[[OCBThemeManager sharedManager].tintColor colorWithAlphaComponent:0.88]
                                              action:@selector(openAccountModule)];
    self.debugButton = [self actionButtonWithTitle:@"开发调试面板"
                                   backgroundColor:[[OCBThemeManager sharedManager].secondaryTextColor colorWithAlphaComponent:0.92]
                                            action:@selector(openDebugPanel)];

    [stackView addArrangedSubview:self.frameworkHomeButton];
    [stackView addArrangedSubview:self.accountButton];
    [stackView addArrangedSubview:self.debugButton];

    return card;
}

- (UIView *)buildActionsCard
{
    UIView *card = [self cardContainer];
    UIStackView *stackView = [self contentStackViewInCard:card spacing:12.0];

    [stackView addArrangedSubview:[self sectionTitleLabelWithText:@"Service Actions"]];
    [stackView addArrangedSubview:[self captionLabelWithText:@"这里保留最小交互入口，用来联调登录态、权限和空态展示。"]];

    self.loginButton = [self actionButtonWithTitle:@"模拟登录"
                                   backgroundColor:[[OCBThemeManager sharedManager].primaryTextColor colorWithAlphaComponent:0.92]
                                            action:@selector(toggleLoginState)];
    self.permissionButton = [self actionButtonWithTitle:@"请求相机权限"
                                        backgroundColor:[[OCBThemeManager sharedManager].primaryTextColor colorWithAlphaComponent:0.78]
                                                 action:@selector(requestCameraPermission)];
    self.emptyButton = [self actionButtonWithTitle:@"切换空态"
                                   backgroundColor:[[OCBThemeManager sharedManager].primaryTextColor colorWithAlphaComponent:0.64]
                                            action:@selector(toggleEmptyState)];

    [stackView addArrangedSubview:self.loginButton];
    [stackView addArrangedSubview:self.permissionButton];
    [stackView addArrangedSubview:self.emptyButton];

    return card;
}

- (UIView *)buildStatusCard
{
    UIView *card = [self cardContainer];
    UIStackView *stackView = [self contentStackViewInCard:card spacing:12.0];

    [stackView addArrangedSubview:[self sectionTitleLabelWithText:@"Runtime Snapshot"]];
    [stackView addArrangedSubview:[self captionLabelWithText:@"确认宿主 App 当前已注册的模块、路由和服务数量。"]];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont monospacedSystemFontOfSize:14.0 weight:UIFontWeightRegular];
    self.statusLabel.textColor = [OCBThemeManager sharedManager].primaryTextColor;
    self.statusLabel.text = @"loading...";

    [stackView addArrangedSubview:self.statusLabel];

    return card;
}

- (void)reloadRuntimeSnapshot
{
    id<OCBRemoteConfigProviding> remoteConfig = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBRemoteConfigProviding)];
    id<OCBUserSessionProviding> sessionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBUserSessionProviding)];
    id<OCBPermissionProviding> permissionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBPermissionProviding)];
    id<OCBStorageProviding> storage = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBStorageProviding)];

    NSString *headline = [remoteConfig stringValueForKey:@"host.headline"
                                            defaultValue:@"__APP_DISPLAY_NAME__ Host Ready"];
    NSString *summary = [remoteConfig stringValueForKey:@"host.summary"
                                           defaultValue:@"宿主工程已经接入 OCAppBox，可以直接从这里继续拆业务模块和页面。"];
    BOOL emptyStateEnabled = [remoteConfig boolValueForKey:@"feature.empty_state_demo" defaultValue:YES];
    OCBUserSession *session = sessionService.currentSession;
    OCBPermissionStatus permissionStatus = [permissionService statusForPermission:@"camera"];
    NSString *lastLaunch = [NSString ocb_stringWithObject:[storage diskObjectForKey:@"__APP_IDENTIFIER__.lastLaunch"]
                                             defaultValue:@"n/a"];

    self.titleLabel.text = headline;
    self.detailLabel.text = summary;
    [self.loginButton setTitle:([sessionService isLoggedIn] ? @"退出登录" : @"模拟登录") forState:UIControlStateNormal];
    self.emptyButton.hidden = !emptyStateEnabled;
    if (!emptyStateEnabled && self.presentingEmptyState) {
        self.presentingEmptyState = NO;
        [self hideEmpty];
    }

    NSString *userName = session.displayName.length > 0 ? session.displayName : @"未登录";
    NSString *loginStatus = [sessionService isLoggedIn] ? @"已登录" : @"未登录";
    self.statusLabel.text = [NSString stringWithFormat:
        @"environment  %@\nmodules      %lu\nroutes       %lu\nservices     %lu\nlogin        %@\nuser         %@\npermission   %@\nroot route   %@\nlast launch  %@",
        self.appContext.environment,
        (unsigned long)self.appContext.moduleManager.modules.count,
        (unsigned long)self.appContext.router.allRoutes.count,
        (unsigned long)self.appContext.serviceRegistry.allRegisteredProtocolNames.count,
        loginStatus,
        userName,
        [self textForPermissionStatus:permissionStatus],
        __APP_PREFIX__RouteRoot,
        lastLaunch];
}

- (void)handleServiceNotification:(NSNotification *)notification
{
    [self reloadRuntimeSnapshot];
}

- (void)openFrameworkHome
{
    [self openRoute:__APP_PREFIX__RouteFrameworkHome
       missingTitle:@"Home Missing"
      missingDetail:@"Framework Home 模块还没有完成注册，请检查框架路由装配链路。"];
}

- (void)openAccountModule
{
    [self openRoute:__APP_PREFIX__RouteAccount
       missingTitle:@"Route Missing"
      missingDetail:@"Account 模块还没有完成注册，请检查 autoRegisterModules 调用链。"];
}

- (void)openDebugPanel
{
    [self openRoute:__APP_PREFIX__RouteDebugPanel
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
                          detail:@"这里可以继续接列表空数据、搜索无结果、断网占位等通用场景。"];
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
        [self reloadRuntimeSnapshot];
        return;
    }

    [self showLoadingWithText:@"Signing in starter user"];
    [authService signInWithUserIdentifier:@"__APP_IDENTIFIER__.starter"
                              displayName:@"__APP_DISPLAY_NAME__ Starter"
                                    token:@"starter-token"
                               completion:^(OCBUserSession *session, NSError *error) {
        [self hideLoading];
        [self reloadRuntimeSnapshot];
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
        [self reloadRuntimeSnapshot];
    }];
}

- (UIView *)cardContainer
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 24.0;
    view.layer.borderWidth = 1.0;
    view.layer.borderColor = [[UIColor colorWithWhite:0.0 alpha:0.06] CGColor];
    view.layer.shadowColor = [[UIColor colorWithWhite:0.0 alpha:0.08] CGColor];
    view.layer.shadowOpacity = 1.0;
    view.layer.shadowRadius = 16.0;
    view.layer.shadowOffset = CGSizeMake(0.0, 8.0);
    return view;
}

- (UIStackView *)contentStackViewInCard:(UIView *)card spacing:(CGFloat)spacing
{
    UIStackView *stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = spacing;

    [card addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:card.topAnchor constant:20.0],
        [stackView.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20.0],
        [stackView.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20.0],
        [stackView.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-20.0]
    ]];

    return stackView;
}

- (UILabel *)eyebrowLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"HOST STARTER";
    label.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightBold];
    label.textColor = [[OCBThemeManager sharedManager].tintColor colorWithAlphaComponent:0.85];
    return label;
}

- (UILabel *)sectionTitleLabelWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
    label.textColor = [OCBThemeManager sharedManager].secondaryTextColor;
    return label;
}

- (UILabel *)captionLabelWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.numberOfLines = 0;
    label.text = text;
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [OCBThemeManager sharedManager].secondaryTextColor;
    return label;
}

- (UIButton *)actionButtonWithTitle:(NSString *)title
                    backgroundColor:(UIColor *)backgroundColor
                             action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    button.backgroundColor = backgroundColor;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 12.0;
    [button.heightAnchor constraintEqualToConstant:52.0].active = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
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
