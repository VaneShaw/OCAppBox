#import "OCBRequest.h"

@implementation OCBRequest

- (instancetype)initWithPath:(NSString *)path
                      method:(OCBHTTPMethod)method
                  parameters:(nullable NSDictionary<NSString *,id> *)parameters
                     headers:(nullable NSDictionary<NSString *,NSString *> *)headers
             timeoutInterval:(NSTimeInterval)timeoutInterval
{
    self = [super init];
    if (self) {
        _path = [path copy] ?: @"";
        _method = method;
        _parameters = [parameters copy] ?: @{};
        _headers = [headers copy] ?: @{};
        _timeoutInterval = timeoutInterval > 0 ? timeoutInterval : 15.0;
    }
    return self;
}

@end
