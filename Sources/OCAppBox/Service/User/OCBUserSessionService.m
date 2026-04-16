#import "OCBUserSessionService.h"

#import "OCBCacheCenter.h"
#import "OCBLogger.h"
#import "OCBUserSession.h"

NSString * const OCBUserSessionDidChangeNotification = @"OCBUserSessionDidChangeNotification";

static NSString * const OCBUserSessionStorageKey = @"service.user.session";

@interface OCBUserSessionService ()

@property (nonatomic, strong, nullable, readwrite) OCBUserSession *currentSession;
@property (nonatomic, strong) id<OCBStorageProviding> storage;
@property (nonatomic, strong) id<OCBLogging> logger;

@end

@implementation OCBUserSessionService

- (instancetype)initWithStorage:(id<OCBStorageProviding>)storage
                         logger:(id<OCBLogging>)logger
{
    self = [super init];
    if (self) {
        _storage = storage;
        _logger = logger;

        id storedObject = [storage diskObjectForKey:OCBUserSessionStorageKey];
        if ([storedObject isKindOfClass:[OCBUserSession class]]) {
            _currentSession = storedObject;
        }
    }
    return self;
}

- (BOOL)isLoggedIn
{
    return self.currentSession.authToken.length > 0;
}

- (void)updateSession:(nullable OCBUserSession *)session
{
    self.currentSession = [session copy];
    [self.storage setDiskObject:self.currentSession forKey:OCBUserSessionStorageKey];

    NSString *message = self.currentSession != nil
        ? [NSString stringWithFormat:@"User session updated: %@", self.currentSession.displayName]
        : @"User session cleared.";
    [self.logger logWithLevel:OCBLogLevelInfo message:message];

    [[NSNotificationCenter defaultCenter] postNotificationName:OCBUserSessionDidChangeNotification
                                                        object:self
                                                      userInfo:nil];
}

- (void)logout
{
    [self updateSession:nil];
}

@end
