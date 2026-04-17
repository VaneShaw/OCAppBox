#import "OCBLogger.h"

static NSString *OCBLogLevelString(OCBLogLevel level)
{
    switch (level) {
        case OCBLogLevelDebug:
            return @"DEBUG";
        case OCBLogLevelInfo:
            return @"INFO";
        case OCBLogLevelWarning:
            return @"WARN";
        case OCBLogLevelError:
            return @"ERROR";
    }

    return @"INFO";
}

@implementation OCBLogger

+ (instancetype)sharedLogger
{
    static OCBLogger *logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[OCBLogger alloc] init];
        logger.minimumLevel = OCBLogLevelDebug;
    });
    return logger;
}

- (void)logWithLevel:(OCBLogLevel)level message:(NSString *)message
{
    if (message.length == 0 || level < self.minimumLevel) {
        return;
    }

    NSLog(@"[OCAppBox][%@] %@", OCBLogLevelString(level), message);
}

- (void)logWithLevel:(OCBLogLevel)level format:(NSString *)format, ...
{
    if (format.length == 0 || level < self.minimumLevel) {
        return;
    }

    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    [self logWithLevel:level message:message];
}

@end
