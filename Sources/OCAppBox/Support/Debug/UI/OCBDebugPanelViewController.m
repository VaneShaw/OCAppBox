#import "OCBDebugPanelViewController.h"

#import "OCBAppContext.h"
#import "OCBModuleProtocol.h"
#import "OCBModuleManager.h"
#import "OCBRouter.h"
#import "OCBServiceRegistry.h"
#import "OCBAppMetadata.h"
#import "OCBRemoteConfigService.h"
#import "OCBPermissionService.h"
#import "OCBUserSession.h"
#import "OCBUserSessionService.h"
#import "OCBThemeManager.h"

@interface OCBDebugPanelViewController ()

@property (nonatomic, weak) OCBAppContext *appContext;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIButton *accountButton;
@property (nonatomic, strong) UIButton *featureButton;
@property (nonatomic, strong) UITextView *snapshotTextView;

@end

@implementation OCBDebugPanelViewController

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

    self.title = @"Debug Panel";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.text = @"Developer Support Panel";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:28.0];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor = [OCBThemeManager sharedManager].primaryTextColor;

    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.font = [UIFont systemFontOfSize:15.0];
    self.detailLabel.textColor = [OCBThemeManager sharedManager].secondaryTextColor;
    self.detailLabel.text = @"这里集中查看模块、路由、服务、登录态、权限和远程配置。";

    self.refreshButton = [self primaryButtonWithTitle:@"刷新快照" action:@selector(reloadSnapshot)];
    self.accountButton = [self secondaryButtonWithTitle:@"打开 Account" action:@selector(openAccountModule)];
    self.featureButton = [self darkButtonWithTitle:@"切换空态开关" action:@selector(toggleEmptyStateFeature)];

    self.snapshotTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.snapshotTextView.editable = NO;
    self.snapshotTextView.selectable = YES;
    self.snapshotTextView.alwaysBounceVertical = YES;
    self.snapshotTextView.backgroundColor = [[OCBThemeManager sharedManager].primaryTextColor colorWithAlphaComponent:0.06];
    self.snapshotTextView.textColor = [OCBThemeManager sharedManager].primaryTextColor;
    self.snapshotTextView.font = [UIFont monospacedSystemFontOfSize:13.0 weight:UIFontWeightRegular];
    self.snapshotTextView.layer.cornerRadius = 16.0;
    self.snapshotTextView.textContainerInset = UIEdgeInsetsMake(18.0, 16.0, 18.0, 16.0);

    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.detailLabel];
    [self.view addSubview:self.refreshButton];
    [self.view addSubview:self.accountButton];
    [self.view addSubview:self.featureButton];
    [self.view addSubview:self.snapshotTextView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleStateChange:)
                                                 name:OCBUserSessionDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleStateChange:)
                                                 name:OCBRemoteConfigDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleStateChange:)
                                                 name:OCBPermissionDidChangeNotification
                                               object:nil];

    [self reloadSnapshot];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat safeTop = self.view.safeAreaInsets.top;
    CGFloat top = MAX(110.0, safeTop + 18.0);
    self.titleLabel.frame = CGRectMake(24.0, top, width - 48.0, 34.0);
    self.detailLabel.frame = CGRectMake(24.0, CGRectGetMaxY(self.titleLabel.frame) + 12.0, width - 48.0, 44.0);
    self.refreshButton.frame = CGRectMake(24.0, CGRectGetMaxY(self.detailLabel.frame) + 18.0, width - 48.0, 48.0);
    self.accountButton.frame = CGRectMake(24.0, CGRectGetMaxY(self.refreshButton.frame) + 12.0, width - 48.0, 48.0);
    self.featureButton.frame = CGRectMake(24.0, CGRectGetMaxY(self.accountButton.frame) + 12.0, width - 48.0, 48.0);
    CGFloat textViewHeight = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.featureButton.frame) - 42.0;
    self.snapshotTextView.frame = CGRectMake(24.0,
                                             CGRectGetMaxY(self.featureButton.frame) + 18.0,
                                             width - 48.0,
                                             MAX(180.0, textViewHeight));
}

- (UIButton *)primaryButtonWithTitle:(NSString *)title action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    button.backgroundColor = [OCBThemeManager sharedManager].tintColor;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 12.0;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)secondaryButtonWithTitle:(NSString *)title action:(SEL)action
{
    UIButton *button = [self primaryButtonWithTitle:title action:action];
    button.backgroundColor = [[OCBThemeManager sharedManager].tintColor colorWithAlphaComponent:0.88];
    return button;
}

- (UIButton *)darkButtonWithTitle:(NSString *)title action:(SEL)action
{
    UIButton *button = [self primaryButtonWithTitle:title action:action];
    button.backgroundColor = [[OCBThemeManager sharedManager].primaryTextColor colorWithAlphaComponent:0.92];
    return button;
}

- (void)handleStateChange:(NSNotification *)notification
{
    [self reloadSnapshot];
}

- (void)reloadSnapshot
{
    id<OCBRemoteConfigProviding> remoteConfig = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBRemoteConfigProviding)];
    id<OCBUserSessionProviding> sessionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBUserSessionProviding)];
    id<OCBPermissionProviding> permissionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBPermissionProviding)];

    NSMutableArray<NSString *> *sections = [[NSMutableArray alloc] init];
    [sections addObject:[self applicationSection]];
    [sections addObject:[self moduleSection]];
    [sections addObject:[self routeSection]];
    [sections addObject:[self serviceSection]];
    [sections addObject:[self sessionSection:sessionService]];
    [sections addObject:[self permissionSection:permissionService]];
    [sections addObject:[self remoteConfigSection:remoteConfig]];

    self.snapshotTextView.text = [sections componentsJoinedByString:@"\n\n"];
}

- (void)openAccountModule
{
    BOOL opened = [self.appContext.router openRoute:@"ocb://account"
                                             params:nil
                                               from:self
                                           animated:YES];
    if (!opened) {
        [self showEmptyWithTitle:@"Route Missing"
                          detail:@"Account 模块路由不可用，请检查自动注册链路。"];
    }
}

- (void)toggleEmptyStateFeature
{
    id<OCBRemoteConfigProviding> remoteConfig = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBRemoteConfigProviding)];
    BOOL enabled = [remoteConfig boolValueForKey:@"feature.empty_state_demo" defaultValue:YES];
    [remoteConfig applyConfigDictionary:@{
        @"feature.empty_state_demo": @(!enabled)
    }];
    [self reloadSnapshot];
}

- (NSString *)applicationSection
{
    NSArray<NSString *> *launchOptionKeys = [[self.appContext.launchOptions allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSString *launchSummary = launchOptionKeys.count > 0 ? [launchOptionKeys componentsJoinedByString:@", "] : @"-";

    return [NSString stringWithFormat:
        @"[Application]\nname        : %@\nbundle      : %@\nversion     : %@\nenvironment : %@\nlaunchKeys  : %@",
        [OCBAppMetadata displayName],
        [OCBAppMetadata bundleIdentifier],
        [OCBAppMetadata versionDisplayString],
        self.appContext.environment.length > 0 ? self.appContext.environment : @"default",
        launchSummary];
}

- (NSString *)moduleSection
{
    NSMutableArray<NSString *> *lines = [[NSMutableArray alloc] init];
    for (id<OCBModuleProtocol> module in self.appContext.moduleManager.modules) {
        NSString *moduleName = @"-";
        if ([module respondsToSelector:@selector(moduleName)]) {
            moduleName = [module moduleName];
        }
        [lines addObject:[NSString stringWithFormat:@"%@ (%@)", moduleName, NSStringFromClass([module class])]];
    }

    NSArray<NSString *> *sortedLines = [lines sortedArrayUsingSelector:@selector(compare:)];
    NSString *content = sortedLines.count > 0 ? [sortedLines componentsJoinedByString:@"\n"] : @"-";
    return [NSString stringWithFormat:@"[Modules]\n%@", content];
}

- (NSString *)routeSection
{
    NSArray<NSString *> *routes = [self.appContext.router allRoutes];
    NSString *content = routes.count > 0 ? [routes componentsJoinedByString:@"\n"] : @"-";
    return [NSString stringWithFormat:@"[Routes]\n%@", content];
}

- (NSString *)serviceSection
{
    NSArray<NSString *> *registeredServices = [self.appContext.serviceRegistry allRegisteredProtocolNames];
    NSArray<NSString *> *instantiatedServices = [self.appContext.serviceRegistry allInstantiatedProtocolNames];
    NSString *registered = registeredServices.count > 0 ? [registeredServices componentsJoinedByString:@", "] : @"-";
    NSString *instantiated = instantiatedServices.count > 0 ? [instantiatedServices componentsJoinedByString:@", "] : @"-";

    return [NSString stringWithFormat:
        @"[Services]\nregistered  : %@\ninstantiated: %@",
        registered,
        instantiated];
}

- (NSString *)sessionSection:(id<OCBUserSessionProviding>)sessionService
{
    OCBUserSession *session = sessionService.currentSession;
    NSString *loginDate = session.loginDate != nil ? [self formattedDateString:session.loginDate] : @"-";
    return [NSString stringWithFormat:
        @"[Session]\nstatus      : %@\nuserId      : %@\nname        : %@\ntoken       : %@\nloginAt     : %@",
        [sessionService isLoggedIn] ? @"signed_in" : @"signed_out",
        session.userIdentifier.length > 0 ? session.userIdentifier : @"-",
        session.displayName.length > 0 ? session.displayName : @"-",
        session.authToken.length > 0 ? [self maskedToken:session.authToken] : @"-",
        loginDate];
}

- (NSString *)permissionSection:(id<OCBPermissionProviding>)permissionService
{
    return [NSString stringWithFormat:
        @"[Permissions]\ncamera      : %@",
        [self textForPermissionStatus:[permissionService statusForPermission:@"camera"]]];
}

- (NSString *)remoteConfigSection:(id<OCBRemoteConfigProviding>)remoteConfig
{
    NSDictionary<NSString *, id> *values = [remoteConfig allValues];
    NSArray<NSString *> *keys = [[values allKeys] sortedArrayUsingSelector:@selector(compare:)];
    if (keys.count == 0) {
        return @"[RemoteConfig]\n-";
    }

    NSMutableArray<NSString *> *lines = [[NSMutableArray alloc] init];
    for (NSString *key in keys) {
        id value = values[key];
        [lines addObject:[NSString stringWithFormat:@"%@ = %@", key, value]];
    }

    return [NSString stringWithFormat:@"[RemoteConfig]\n%@", [lines componentsJoinedByString:@"\n"]];
}

- (NSString *)maskedToken:(NSString *)token
{
    if (token.length <= 8) {
        return token;
    }

    NSString *suffix = [token substringFromIndex:(token.length - 8)];
    return [NSString stringWithFormat:@"...%@", suffix];
}

- (NSString *)formattedDateString:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter stringFromDate:date];
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
