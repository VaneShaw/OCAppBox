#import "OCBNetworkError.h"

NSErrorDomain const OCBNetworkErrorDomain = @"com.ocappbox.network";
NSString * const OCBNetworkErrorStatusCodeUserInfoKey = @"statusCode";
NSString * const OCBNetworkErrorResponseObjectUserInfoKey = @"responseObject";
NSString * const OCBNetworkErrorBusinessCodeUserInfoKey = @"businessCode";
NSString * const OCBNetworkErrorBusinessMessageUserInfoKey = @"businessMessage";
NSString * const OCBNetworkErrorBusinessDataUserInfoKey = @"businessData";

@implementation OCBNetworkError

+ (NSError *)invalidRequestWithReason:(NSString *)reason
{
    return [NSError errorWithDomain:OCBNetworkErrorDomain
                               code:OCBNetworkErrorCodeInvalidRequest
                           userInfo:@{
        NSLocalizedDescriptionKey: reason.length > 0 ? reason : @"Invalid network request."
    }];
}

+ (NSError *)invalidURLForPath:(NSString *)path
{
    NSString *message = path.length > 0
        ? [NSString stringWithFormat:@"Invalid request URL for path: %@", path]
        : @"Invalid request URL.";
    return [NSError errorWithDomain:OCBNetworkErrorDomain
                               code:OCBNetworkErrorCodeInvalidURL
                           userInfo:@{
        NSLocalizedDescriptionKey: message
    }];
}

+ (NSError *)serializationFailedWithUnderlyingError:(nullable NSError *)underlyingError
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:@{
        NSLocalizedDescriptionKey: @"Failed to serialize network response."
    }];
    if (underlyingError != nil) {
        userInfo[NSUnderlyingErrorKey] = underlyingError;
    }

    return [NSError errorWithDomain:OCBNetworkErrorDomain
                               code:OCBNetworkErrorCodeSerializationFailed
                           userInfo:userInfo];
}

+ (NSError *)unexpectedResponseWithResponseObject:(nullable id)responseObject
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:@{
        NSLocalizedDescriptionKey: @"Unexpected network response."
    }];
    if (responseObject != nil) {
        userInfo[OCBNetworkErrorResponseObjectUserInfoKey] = responseObject;
    }

    return [NSError errorWithDomain:OCBNetworkErrorDomain
                               code:OCBNetworkErrorCodeUnexpectedResponse
                           userInfo:userInfo];
}

+ (NSError *)httpStatusError:(NSInteger)statusCode
               responseObject:(nullable id)responseObject
              underlyingError:(nullable NSError *)underlyingError
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Request failed with HTTP status %ld.", (long)statusCode],
        OCBNetworkErrorStatusCodeUserInfoKey: @(statusCode)
    }];
    if (responseObject != nil) {
        userInfo[OCBNetworkErrorResponseObjectUserInfoKey] = responseObject;
    }
    if (underlyingError != nil) {
        userInfo[NSUnderlyingErrorKey] = underlyingError;
    }

    return [NSError errorWithDomain:OCBNetworkErrorDomain
                               code:OCBNetworkErrorCodeHTTPStatus
                           userInfo:userInfo];
}

+ (NSError *)businessErrorWithCode:(nullable NSNumber *)businessCode
                           message:(nullable NSString *)message
                    responseObject:(nullable id)responseObject
                              data:(nullable id)data
{
    NSString *description = nil;
    if (message.length > 0) {
        description = message;
    } else if (businessCode != nil) {
        description = [NSString stringWithFormat:@"Request failed with business code %@.", businessCode];
    } else {
        description = @"Request failed with business error.";
    }

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:@{
        NSLocalizedDescriptionKey: description
    }];
    if (businessCode != nil) {
        userInfo[OCBNetworkErrorBusinessCodeUserInfoKey] = businessCode;
    }
    if (message.length > 0) {
        userInfo[OCBNetworkErrorBusinessMessageUserInfoKey] = message;
    }
    if (responseObject != nil) {
        userInfo[OCBNetworkErrorResponseObjectUserInfoKey] = responseObject;
    }
    if (data != nil) {
        userInfo[OCBNetworkErrorBusinessDataUserInfoKey] = data;
    }

    return [NSError errorWithDomain:OCBNetworkErrorDomain
                               code:OCBNetworkErrorCodeBusiness
                           userInfo:userInfo];
}

@end
