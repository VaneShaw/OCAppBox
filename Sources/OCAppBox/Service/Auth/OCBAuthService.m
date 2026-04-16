#import "OCBAuthService.h"

#import "OCBFoundationMacros.h"
#import "OCBLogger.h"
#import "OCBUserSession.h"
#import "OCBUserSessionService.h"

@interface OCBAuthService ()

@property (nonatomic, strong) id<OCBUserSessionProviding> userSessionService;
@property (nonatomic, strong) id<OCBLogging> logger;

@end

@implementation OCBAuthService

- (instancetype)initWithUserSessionService:(id<OCBUserSessionProviding>)userSessionService
                                    logger:(id<OCBLogging>)logger
{
    self = [super init];
    if (self) {
        _userSessionService = userSessionService;
        _logger = logger;
    }
    return self;
}

- (void)signInWithUserIdentifier:(NSString *)userIdentifier
                     displayName:(NSString *)displayName
                           token:(NSString *)token
                      completion:(nullable OCBAuthCompletion)completion
{
    [self.logger logWithLevel:OCBLogLevelInfo
                      message:[NSString stringWithFormat:@"Start signing in user: %@", displayName]];

    OCBUserSession *session = [[OCBUserSession alloc] initWithUserIdentifier:userIdentifier
                                                                 displayName:displayName
                                                                   authToken:token
                                                                   loginDate:[NSDate date]];
    [self.userSessionService updateSession:session];
    OCB_SAFE_BLOCK(completion, session, nil);
}

- (void)signOut
{
    [self.logger logWithLevel:OCBLogLevelInfo message:@"Sign out current user."];
    [self.userSessionService logout];
}

@end
