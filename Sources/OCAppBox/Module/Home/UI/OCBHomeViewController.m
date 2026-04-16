#import "OCBHomeViewController.h"

#import "OCBAppContext.h"
#import "OCBRouter.h"
#import "OCBServiceRegistry.h"
#import "OCBAppMetadata.h"
#import "OCBRemoteConfigService.h"
#import "OCBPermissionService.h"
#import "OCBUserSession.h"
#import "OCBUserSessionService.h"
#import "OCBThemeManager.h"

@interface OCBHomeViewController ()

@property (nonatomic, weak) OCBAppContext *appContext;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *accountButton;
@property (nonatomic, strong) UIButton *permissionButton;
@property (nonatomic, strong) UIButton *emptyButton;
@property (nonatomic, strong) UIButton *debugButton;
@property (nonatomic, assign) BOOL presentingEmptyState;

@end

@implementation OCBHomeViewController

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

    self.title = @"Home";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.text = @"Rapid App Bootstrap";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:30.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [OCBThemeManager sharedManager].primaryTextColor;

    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.font = [UIFont systemFontOfSize:16.0];
    self.detailLabel.textColor = [OCBThemeManager sharedManager].secondaryTextColor;
    self.detailLabel.text = @"Home 模块负责承接框架启动后的首页能力演示。";

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.textAlignment = NSTextAlignmentLeft;
    self.statusLabel.font = [UIFont monospacedSystemFontOfSize:14.0 weight:UIFontWeightRegular];
    self.statusLabel.textColor = [OCBThemeManager sharedManager].primaryTextColor;

    self.accountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.accountButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    self.accountButton.backgroundColor = [OCBThemeManager sharedManager].tintColor;
    [self.accountButton setTitle:@"进入 Account 模块" forState:UIControlStateNormal];
    [self.accountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.accountButton.layer.cornerRadius = 12.0;
    [self.accountButton addTarget:self action:@selector(openAccountModule) forControlEvents:UIControlEventTouchUpInside];

    self.permissionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.permissionButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    self.permissionButton.backgroundColor = [[OCBThemeManager sharedManager].tintColor colorWithAlphaComponent:0.88];
    [self.permissionButton setTitle:@"请求相机权限" forState:UIControlStateNormal];
    [self.permissionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.permissionButton.layer.cornerRadius = 12.0;
    [self.permissionButton addTarget:self action:@selector(requestCameraPermission) forControlEvents:UIControlEventTouchUpInside];

    self.emptyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.emptyButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    self.emptyButton.backgroundColor = [[OCBThemeManager sharedManager].primaryTextColor colorWithAlphaComponent:0.92];
    [self.emptyButton setTitle:@"切换空态" forState:UIControlStateNormal];
    [self.emptyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.emptyButton.layer.cornerRadius = 12.0;
    [self.emptyButton addTarget:self action:@selector(toggleEmptyState) forControlEvents:UIControlEventTouchUpInside];

    self.debugButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.debugButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    self.debugButton.backgroundColor = [[OCBThemeManager sharedManager].secondaryTextColor colorWithAlphaComponent:0.92];
    [self.debugButton setTitle:@"开发调试面板" forState:UIControlStateNormal];
    [self.debugButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.debugButton.layer.cornerRadius = 12.0;
    [self.debugButton addTarget:self action:@selector(openDebugPanel) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.detailLabel];
    [self.view addSubview:self.statusLabel];
    [self.view addSubview:self.accountButton];
    [self.view addSubview:self.permissionButton];
    [self.view addSubview:self.emptyButton];
    [self.view addSubview:self.debugButton];

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

    [self showLoadingWithText:@"Preparing Home module"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat top = 128.0;
    self.titleLabel.frame = CGRectMake(24.0, top, width - 48.0, 36.0);
    self.detailLabel.frame = CGRectMake(24.0, CGRectGetMaxY(self.titleLabel.frame) + 16.0, width - 48.0, 74.0);
    self.statusLabel.frame = CGRectMake(24.0, CGRectGetMaxY(self.detailLabel.frame) + 16.0, width - 48.0, 148.0);
    self.accountButton.frame = CGRectMake(32.0, CGRectGetMaxY(self.statusLabel.frame) + 18.0, width - 64.0, 48.0);
    self.permissionButton.frame = CGRectMake(32.0, CGRectGetMaxY(self.accountButton.frame) + 12.0, width - 64.0, 48.0);
    self.emptyButton.frame = CGRectMake(32.0, CGRectGetMaxY(self.permissionButton.frame) + 12.0, width - 64.0, 48.0);
    self.debugButton.frame = CGRectMake(32.0, CGRectGetMaxY(self.emptyButton.frame) + 12.0, width - 64.0, 48.0);
}

- (void)reloadServiceState
{
    id<OCBRemoteConfigProviding> remoteConfig = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBRemoteConfigProviding)];
    id<OCBUserSessionProviding> sessionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBUserSessionProviding)];
    id<OCBPermissionProviding> permissionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBPermissionProviding)];

    NSString *headline = [remoteConfig stringValueForKey:@"home.headline" defaultValue:@"Rapid App Bootstrap"];
    NSString *copy = [remoteConfig stringValueForKey:@"home.welcome.copy"
                                        defaultValue:@"Home 模块负责展示路由、权限和 UI 基座，Account 模块负责账号与配置服务演示。"];
    BOOL emptyStateEnabled = [remoteConfig boolValueForKey:@"feature.empty_state_demo" defaultValue:YES];
    OCBPermissionStatus permissionStatus = [permissionService statusForPermission:@"camera"];
    OCBUserSession *session = sessionService.currentSession;

    self.titleLabel.text = headline;
    self.detailLabel.text = copy;
    self.emptyButton.hidden = !emptyStateEnabled;
    if (!emptyStateEnabled && self.presentingEmptyState) {
        self.presentingEmptyState = NO;
        [self hideEmpty];
    }

    NSString *loginStatus = [sessionService isLoggedIn] ? @"signed_in" : @"signed_out";
    NSString *userName = session.displayName.length > 0 ? session.displayName : @"guest";
    self.statusLabel.text = [NSString stringWithFormat:
        @"app         : %@\nbundle      : %@\nversion     : %@\nroutes      : %lu\nconfigKeys  : %lu\nlogin       : %@\nuser        : %@\npermission  : %@",
        [OCBAppMetadata displayName],
        [OCBAppMetadata bundleIdentifier],
        [OCBAppMetadata versionDisplayString],
        (unsigned long)[[self.appContext.router allRoutes] count],
        (unsigned long)[[remoteConfig allValues] count],
        loginStatus,
        userName,
        [self textForPermissionStatus:permissionStatus]];
}

- (void)handleServiceNotification:(NSNotification *)notification
{
    [self reloadServiceState];
}

- (void)openAccountModule
{
    BOOL opened = [self.appContext.router openRoute:@"ocb://account"
                                             params:nil
                                               from:self
                                           animated:YES];
    if (!opened) {
        [self showEmptyWithTitle:@"Route Missing"
                          detail:@"Account 模块还没有完成注册，请检查 autoRegisterModules 调用链。"];
    }
}

- (void)toggleEmptyState
{
    self.presentingEmptyState = !self.presentingEmptyState;
    if (self.presentingEmptyState) {
        [self showEmptyWithTitle:@"Home Empty State"
                          detail:@"这里可以承接列表空数据、搜索无结果、网络异常等通用空态能力。"];
    } else {
        [self hideEmpty];
    }
}

- (void)openDebugPanel
{
    BOOL opened = [self.appContext.router openRoute:@"ocb://support/debug"
                                             params:nil
                                               from:self
                                           animated:YES];
    if (!opened) {
        [self showEmptyWithTitle:@"Support Missing"
                          detail:@"调试面板还没有完成注册，请检查 Support 模块是否已经自动装配。"];
    }
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
