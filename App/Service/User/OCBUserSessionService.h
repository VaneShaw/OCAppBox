#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBUserSession;
@protocol OCBLogging;
@protocol OCBStorageProviding;

FOUNDATION_EXPORT NSString * const OCBUserSessionDidChangeNotification;

@protocol OCBUserSessionProviding <NSObject>

@property (nonatomic, strong, readonly, nullable) OCBUserSession *currentSession;

- (BOOL)isLoggedIn;
- (void)updateSession:(nullable OCBUserSession *)session;
- (void)logout;

@end

@interface OCBUserSessionService : NSObject <OCBUserSessionProviding>

- (instancetype)initWithStorage:(id<OCBStorageProviding>)storage
                         logger:(id<OCBLogging>)logger NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
