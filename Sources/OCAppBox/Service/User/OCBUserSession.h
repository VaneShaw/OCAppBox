#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCBUserSession : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, copy, readonly) NSString *userIdentifier;
@property (nonatomic, copy, readonly) NSString *displayName;
@property (nonatomic, copy, readonly) NSString *authToken;
@property (nonatomic, strong, readonly) NSDate *loginDate;

- (instancetype)initWithUserIdentifier:(NSString *)userIdentifier
                           displayName:(NSString *)displayName
                             authToken:(NSString *)authToken
                             loginDate:(nullable NSDate *)loginDate NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
