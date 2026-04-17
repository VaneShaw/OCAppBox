#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBUserSession;
@protocol OCBLogging;
@protocol OCBUserSessionProviding;

typedef void (^OCBAuthCompletion)(OCBUserSession * _Nullable session, NSError * _Nullable error);

@protocol OCBAuthenticating <NSObject>

- (void)signInWithUserIdentifier:(NSString *)userIdentifier
                     displayName:(NSString *)displayName
                           token:(NSString *)token
                      completion:(nullable OCBAuthCompletion)completion;
- (void)signOut;

@end

@interface OCBAuthService : NSObject <OCBAuthenticating>

- (instancetype)initWithUserSessionService:(id<OCBUserSessionProviding>)userSessionService
                                    logger:(id<OCBLogging>)logger NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
