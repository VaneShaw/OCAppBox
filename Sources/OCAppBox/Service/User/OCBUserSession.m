#import "OCBUserSession.h"

@implementation OCBUserSession

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithUserIdentifier:(NSString *)userIdentifier
                           displayName:(NSString *)displayName
                             authToken:(NSString *)authToken
                             loginDate:(nullable NSDate *)loginDate
{
    self = [super init];
    if (self) {
        _userIdentifier = [userIdentifier copy] ?: @"";
        _displayName = [displayName copy] ?: @"";
        _authToken = [authToken copy] ?: @"";
        _loginDate = loginDate ?: [NSDate date];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSString *userIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:@"userIdentifier"] ?: @"";
    NSString *displayName = [coder decodeObjectOfClass:[NSString class] forKey:@"displayName"] ?: @"";
    NSString *authToken = [coder decodeObjectOfClass:[NSString class] forKey:@"authToken"] ?: @"";
    NSDate *loginDate = [coder decodeObjectOfClass:[NSDate class] forKey:@"loginDate"];
    return [self initWithUserIdentifier:userIdentifier
                            displayName:displayName
                              authToken:authToken
                              loginDate:loginDate];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.userIdentifier forKey:@"userIdentifier"];
    [coder encodeObject:self.displayName forKey:@"displayName"];
    [coder encodeObject:self.authToken forKey:@"authToken"];
    [coder encodeObject:self.loginDate forKey:@"loginDate"];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[OCBUserSession allocWithZone:zone] initWithUserIdentifier:self.userIdentifier
                                                           displayName:self.displayName
                                                             authToken:self.authToken
                                                             loginDate:self.loginDate];
}

@end
