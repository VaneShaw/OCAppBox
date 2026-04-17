#import "OCBRequest.h"

@implementation OCBRequest

+ (instancetype)requestWithPath:(NSString *)path method:(OCBHTTPMethod)method
{
    return [self requestWithPath:path method:method parameters:nil];
}

+ (instancetype)requestWithPath:(NSString *)path
                         method:(OCBHTTPMethod)method
                     parameters:(nullable NSDictionary<NSString *,id> *)parameters
{
    return [self requestWithPath:path method:method parameters:parameters headers:nil];
}

+ (instancetype)requestWithPath:(NSString *)path
                         method:(OCBHTTPMethod)method
                     parameters:(nullable NSDictionary<NSString *,id> *)parameters
                        headers:(nullable NSDictionary<NSString *,NSString *> *)headers
{
    return [[self alloc] initWithPath:path
                               method:method
                           parameters:parameters
                              headers:headers
                      timeoutInterval:0.0];
}

+ (instancetype)formRequestWithPath:(NSString *)path
                             method:(OCBHTTPMethod)method
                         parameters:(nullable NSDictionary<NSString *,id> *)parameters
                            headers:(nullable NSDictionary<NSString *,NSString *> *)headers
{
    return [[self alloc] initWithPath:path
                               method:method
                           parameters:parameters
                              headers:headers
                requestSerializerType:OCBRequestSerializerTypeFormURLEncoded
               responseSerializerType:OCBResponseSerializerTypeJSON
                      timeoutInterval:0.0];
}

+ (instancetype)GET:(NSString *)path parameters:(nullable NSDictionary<NSString *,id> *)parameters
{
    return [self requestWithPath:path method:OCBHTTPMethodGET parameters:parameters];
}

+ (instancetype)POST:(NSString *)path parameters:(nullable NSDictionary<NSString *,id> *)parameters
{
    return [self requestWithPath:path method:OCBHTTPMethodPOST parameters:parameters];
}

+ (instancetype)PUT:(NSString *)path parameters:(nullable NSDictionary<NSString *,id> *)parameters
{
    return [self requestWithPath:path method:OCBHTTPMethodPUT parameters:parameters];
}

+ (instancetype)DELETE:(NSString *)path parameters:(nullable NSDictionary<NSString *,id> *)parameters
{
    return [self requestWithPath:path method:OCBHTTPMethodDELETE parameters:parameters];
}

- (instancetype)initWithPath:(NSString *)path
                      method:(OCBHTTPMethod)method
                  parameters:(nullable NSDictionary<NSString *,id> *)parameters
                     headers:(nullable NSDictionary<NSString *,NSString *> *)headers
             timeoutInterval:(NSTimeInterval)timeoutInterval
{
    return [self initWithPath:path
                       method:method
                   parameters:parameters
                      headers:headers
        requestSerializerType:OCBRequestSerializerTypeJSON
       responseSerializerType:OCBResponseSerializerTypeJSON
              timeoutInterval:timeoutInterval];
}

- (instancetype)initWithPath:(NSString *)path
                      method:(OCBHTTPMethod)method
                  parameters:(nullable NSDictionary<NSString *,id> *)parameters
                     headers:(nullable NSDictionary<NSString *,NSString *> *)headers
       requestSerializerType:(OCBRequestSerializerType)requestSerializerType
      responseSerializerType:(OCBResponseSerializerType)responseSerializerType
             timeoutInterval:(NSTimeInterval)timeoutInterval
{
    self = [super init];
    if (self) {
        _requestIdentifier = [[NSUUID UUID] UUIDString];
        _path = [path copy] ?: @"";
        _method = method;
        _parameters = [parameters copy] ?: @{};
        _headers = [headers copy] ?: @{};
        _requestSerializerType = requestSerializerType;
        _responseSerializerType = responseSerializerType;
        _timeoutInterval = timeoutInterval > 0 ? timeoutInterval : 15.0;
    }
    return self;
}

@end
