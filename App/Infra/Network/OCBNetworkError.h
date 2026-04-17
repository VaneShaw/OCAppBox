#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const OCBNetworkErrorDomain;
FOUNDATION_EXPORT NSString * const OCBNetworkErrorStatusCodeUserInfoKey;
FOUNDATION_EXPORT NSString * const OCBNetworkErrorResponseObjectUserInfoKey;
FOUNDATION_EXPORT NSString * const OCBNetworkErrorBusinessCodeUserInfoKey;
FOUNDATION_EXPORT NSString * const OCBNetworkErrorBusinessMessageUserInfoKey;
FOUNDATION_EXPORT NSString * const OCBNetworkErrorBusinessDataUserInfoKey;

typedef NS_ENUM(NSInteger, OCBNetworkErrorCode) {
    OCBNetworkErrorCodeInvalidRequest = -1000,
    OCBNetworkErrorCodeInvalidURL = -1001,
    OCBNetworkErrorCodeSerializationFailed = -1002,
    OCBNetworkErrorCodeUnexpectedResponse = -1003,
    OCBNetworkErrorCodeHTTPStatus = -1004,
    OCBNetworkErrorCodeBusiness = -1005,
};

@interface OCBNetworkError : NSObject

+ (NSError *)invalidRequestWithReason:(NSString *)reason;
+ (NSError *)invalidURLForPath:(NSString *)path;
+ (NSError *)serializationFailedWithUnderlyingError:(nullable NSError *)underlyingError;
+ (NSError *)unexpectedResponseWithResponseObject:(nullable id)responseObject;
+ (NSError *)httpStatusError:(NSInteger)statusCode
               responseObject:(nullable id)responseObject
              underlyingError:(nullable NSError *)underlyingError;
+ (NSError *)businessErrorWithCode:(nullable NSNumber *)businessCode
                           message:(nullable NSString *)message
                    responseObject:(nullable id)responseObject
                              data:(nullable id)data;

@end

NS_ASSUME_NONNULL_END
