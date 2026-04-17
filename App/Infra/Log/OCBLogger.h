#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OCBLogLevel) {
    OCBLogLevelDebug = 0,
    OCBLogLevelInfo = 1,
    OCBLogLevelWarning = 2,
    OCBLogLevelError = 3,
};

@protocol OCBLogging <NSObject>

- (void)logWithLevel:(OCBLogLevel)level message:(NSString *)message;

@end

@interface OCBLogger : NSObject <OCBLogging>

@property (nonatomic, assign) OCBLogLevel minimumLevel;

+ (instancetype)sharedLogger;
- (void)logWithLevel:(OCBLogLevel)level
              format:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);

@end

NS_ASSUME_NONNULL_END
