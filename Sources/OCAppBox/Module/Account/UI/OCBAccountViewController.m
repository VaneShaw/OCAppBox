#import "OCBAccountViewController.h"

#import "OCBAppContext.h"
#import "OCBRouter.h"
#import "OCBServiceRegistry.h"
#import "OCBAuthService.h"
#import "OCBRemoteConfigService.h"
#import "OCBUserSession.h"
#import "OCBUserSessionService.h"
#import "OCBThemeManager.h"

@interface OCBAccountViewController ()

@property (nonatomic, weak) OCBAppContext *appContext;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *authButton;
@property (nonatomic, strong) UIButton *configButton;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation OCBAccountViewController

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

    self.title = @"Account";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.text = @"Account Service Center";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:30.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [OCBThemeManager sharedManager].primaryTextColor;

    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.font = [UIFont systemFontOfSize:16.0];
    self.detailLabel.textColor = [OCBThemeManager sharedManager].secondaryTextColor;
    self.detailLabel.text = @"Account 模块直接消费 Auth、UserSession 和 RemoteConfig。";

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.textAlignment = NSTextAlignmentLeft;
    self.statusLabel.font = [UIFont monospacedSystemFontOfSize:14.0 weight:UIFontWeightRegular];
    self.statusLabel.textColor = [OCBThemeManager sharedManager].primaryTextColor;

    self.authButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.authButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    self.authButton.backgroundColor = [OCBThemeManager sharedManager].tintColor;
    [self.authButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.authButton.layer.cornerRadius = 12.0;
    [self.authButton addTarget:self action:@selector(toggleLoginState) forControlEvents:UIControlEventTouchUpInside];

    self.configButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.configButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    self.configButton.backgroundColor = [[OCBThemeManager sharedManager].tintColor colorWithAlphaComponent:0.88];
    [self.configButton setTitle:@"刷新远程配置" forState:UIControlStateNormal];
    [self.configButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.configButton.layer.cornerRadius = 12.0;
    [self.configButton addTarget:self action:@selector(applyRemoteConfig) forControlEvents:UIControlEventTouchUpInside];

    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    self.backButton.backgroundColor = [[OCBThemeManager sharedManager].primaryTextColor colorWithAlphaComponent:0.92];
    [self.backButton setTitle:@"返回 Home" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backButton.layer.cornerRadius = 12.0;
    [self.backButton addTarget:self action:@selector(returnToHome) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.detailLabel];
    [self.view addSubview:self.statusLabel];
    [self.view addSubview:self.authButton];
    [self.view addSubview:self.configButton];
    [self.view addSubview:self.backButton];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleServiceNotification:)
                                                 name:OCBUserSessionDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleServiceNotification:)
                                                 name:OCBRemoteConfigDidChangeNotification
                                               object:nil];

    [self reloadAccountState];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat top = 180.0;
    self.titleLabel.frame = CGRectMake(24.0, top, width - 48.0, 36.0);
    self.detailLabel.frame = CGRectMake(24.0, CGRectGetMaxY(self.titleLabel.frame) + 18.0, width - 48.0, 72.0);
    self.statusLabel.frame = CGRectMake(24.0, CGRectGetMaxY(self.detailLabel.frame) + 18.0, width - 48.0, 138.0);
    self.authButton.frame = CGRectMake(32.0, CGRectGetMaxY(self.statusLabel.frame) + 22.0, width - 64.0, 52.0);
    self.configButton.frame = CGRectMake(32.0, CGRectGetMaxY(self.authButton.frame) + 14.0, width - 64.0, 52.0);
    self.backButton.frame = CGRectMake(32.0, CGRectGetMaxY(self.configButton.frame) + 14.0, width - 64.0, 52.0);
}

- (void)reloadAccountState
{
    id<OCBRemoteConfigProviding> remoteConfig = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBRemoteConfigProviding)];
    id<OCBUserSessionProviding> sessionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBUserSessionProviding)];
    OCBUserSession *session = sessionService.currentSession;
    NSInteger refreshVersion = [remoteConfig integerValueForKey:@"account.refresh.version" defaultValue:0];

    self.titleLabel.text = [remoteConfig stringValueForKey:@"account.headline" defaultValue:@"Account Service Center"];
    self.detailLabel.text = [remoteConfig stringValueForKey:@"account.summary"
                                               defaultValue:@"这里演示 Auth、UserSession 和 RemoteConfig 的组合接入。"];
    [self.authButton setTitle:([sessionService isLoggedIn] ? @"退出登录" : @"模拟登录") forState:UIControlStateNormal];

    NSString *userIdentifier = session.userIdentifier.length > 0 ? session.userIdentifier : @"-";
    NSString *displayName = session.displayName.length > 0 ? session.displayName : @"guest";
    NSString *tokenText = session.authToken.length > 0 ? [self maskedToken:session.authToken] : @"-";
    NSString *loginDateText = session.loginDate != nil ? [self formattedDateString:session.loginDate] : @"-";
    self.statusLabel.text = [NSString stringWithFormat:
        @"login       : %@\nuserId      : %@\nname        : %@\ntoken       : %@\nloginAt     : %@\nconfigVer   : %ld\nroutes      : %lu",
        [sessionService isLoggedIn] ? @"signed_in" : @"signed_out",
        userIdentifier,
        displayName,
        tokenText,
        loginDateText,
        (long)refreshVersion,
        (unsigned long)[[self.appContext.router allRoutes] count]];
}

- (void)handleServiceNotification:(NSNotification *)notification
{
    [self reloadAccountState];
}

- (void)toggleLoginState
{
    id<OCBAuthenticating> authService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBAuthenticating)];
    id<OCBUserSessionProviding> sessionService = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBUserSessionProviding)];

    if ([sessionService isLoggedIn]) {
        [authService signOut];
        [self reloadAccountState];
        return;
    }

    [self showLoadingWithText:@"Signing in account demo user"];
    [authService signInWithUserIdentifier:@"2001"
                              displayName:@"OCAppBox User"
                                    token:@"account-demo-token-2001"
                               completion:^(OCBUserSession *session, NSError *error) {
        [self hideLoading];
        [self reloadAccountState];
    }];
}

- (void)applyRemoteConfig
{
    id<OCBRemoteConfigProviding> remoteConfig = [self.appContext.serviceRegistry serviceForProtocol:@protocol(OCBRemoteConfigProviding)];
    NSInteger refreshVersion = [remoteConfig integerValueForKey:@"account.refresh.version" defaultValue:0] + 1;

    [self showLoadingWithText:@"Refreshing remote config"];
    [remoteConfig applyConfigDictionary:@{
        @"home.headline": [NSString stringWithFormat:@"Rapid App Bootstrap v%ld", (long)refreshVersion],
        @"home.welcome.copy": @"首页文案已由 Account 模块通过 RemoteConfig 动态刷新。",
        @"account.headline": @"Account Service Center",
        @"account.summary": [NSString stringWithFormat:@"第 %ld 次配置刷新已生效，返回 Home 页面可以看到跨模块联动。", (long)refreshVersion],
        @"account.refresh.version": @(refreshVersion)
    }];
    [self hideLoading];
    [self reloadAccountState];
}

- (void)returnToHome
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self.appContext.router openRoute:@"ocb://home"
                               params:nil
                                 from:self
                             animated:YES];
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

@end
